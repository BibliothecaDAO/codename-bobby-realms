#[derive(Copy, Drop, Serde, Hash, starknet::Store)]
struct Seed {
    background: u32,
    armour: u32,
    jewellry: u32,
    mask: u32,
    weapon: u32,
}

#[starknet::interface]
trait ISeeder<TContractState> {
    fn generate_seed(self: @TContractState, token_id: u256, descriptor_addr: starknet::ContractAddress) -> Seed;
}

#[starknet::contract]
mod Seeder {
    use core::result::ResultTrait;
    use core::box::BoxTrait;
    
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use starknet::ContractAddress;
    use core::poseidon::poseidon_hash_span;
    use core::u256;
    use blob::descriptor::{IDescriptorDispatcher, IDescriptorDispatcherTrait};
    use blob::seeder::Seed;
    use alexandria_math::{BitShift, U256BitShift};


    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl Seeder of super::ISeeder<ContractState> {

        fn generate_seed(
            self: @ContractState, token_id: u256,  descriptor_addr: starknet::ContractAddress
        ) -> Seed {

            let descriptor = IDescriptorDispatcher{contract_address: descriptor_addr};

            let block_number = starknet::get_block_info().unbox().block_number;
            let previous_block_hash = starknet::get_block_hash_syscall(block_number - 1).unwrap();
            let pseudorandomness: u256 = poseidon_hash_span(
                    array![previous_block_hash, token_id.low.into(), token_id.high.into()].span()
                ).into();

            let background_count: u256 = descriptor.background_count().into();
            let armour_count : u256 = descriptor.armour_count().into();
            let jewellry_count : u256 = descriptor.jewellry_count().into();
            let mask_count: u256 = descriptor.mask_count().into();
            let weapon_count: u256 = descriptor.weapon_count().into();

            return Seed {
                background: (pseudorandomness % background_count).try_into().unwrap(),
                armour: (BitShift::shr(background_count, 48) % armour_count).try_into().unwrap(),
                jewellry: (BitShift::shr(background_count, 96) % jewellry_count).try_into().unwrap(),
                mask: (BitShift::shr(background_count, 144) % mask_count).try_into().unwrap(),
                weapon: (BitShift::shr(background_count, 192) % weapon_count).try_into().unwrap(),
            };
        }
        
    }
}