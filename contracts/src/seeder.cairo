use blob::types::seeder::Seed;

#[starknet::interface]
trait ISeeder<TContractState> {
    fn generate_seed(
        self: @TContractState,
        token_id: u256,
        descriptor_addr: starknet::ContractAddress,
        salt: felt252
    ) -> Seed;
}

#[starknet::contract]
mod Seeder {
    use alexandria_math::{BitShift, U256BitShift};
    use blob::descriptor::{IDescriptorDispatcher, IDescriptorDispatcherTrait};
    use blob::types::seeder::Seed;
    use core::box::BoxTrait;
    use core::poseidon::poseidon_hash_span;
    use core::result::ResultTrait;
    use core::u256;

    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use starknet::ContractAddress;


    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl Seeder of super::ISeeder<ContractState> {
        fn generate_seed(
            self: @ContractState,
            token_id: u256,
            descriptor_addr: starknet::ContractAddress,
            salt: felt252
        ) -> Seed {
            let descriptor = IDescriptorDispatcher { contract_address: descriptor_addr };

            let block_timestamp = starknet::get_block_timestamp();
            let randomness: u256 = poseidon_hash_span(
                array![block_timestamp.into(), token_id.low.into(), token_id.high.into()].span()
            )
                .into();

            let background_count: u256 = descriptor.background_count().into();
            let armour_count: u256 = descriptor.armour_count().into();
            let jewellry_count: u256 = descriptor.jewellry_count().into();
            let mask_count: u256 = descriptor.mask_count().into();
            let weapon_count: u256 = descriptor.weapon_count().into();

            return Seed {
                background: (randomness % background_count).try_into().unwrap(),
                armour: (BitShift::shr(randomness, 48) % armour_count).try_into().unwrap(),
                jewellry: (BitShift::shr(randomness, 96) % jewellry_count).try_into().unwrap(),
                mask: (BitShift::shr(randomness, 144) % mask_count).try_into().unwrap(),
                weapon: (BitShift::shr(randomness, 192) % weapon_count).try_into().unwrap(),
            };
        }
    }
}
