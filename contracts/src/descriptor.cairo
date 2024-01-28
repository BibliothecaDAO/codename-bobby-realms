use blob::seeder::Seed;

#[starknet::interface]
trait IDescriptor<TContractState> {
    fn armour_count(self: @TContractState) -> u32;
    fn background_count(self: @TContractState) -> u32;
    fn jewellry_count(self: @TContractState) -> u32;
    fn mask_count(self: @TContractState) -> u32;
    fn weapon_count(self: @TContractState) -> u32;

    fn token_uri(self: @TContractState, token_id: u256, seed: Seed) -> ByteArray;
}


#[starknet::interface]
trait IDescriptorTraitsMetadata<TContractState> {
    fn armour_count(self: @TContractState) -> u32;
    fn background_count(self: @TContractState) -> u32;
    fn jewellry_count(self: @TContractState) -> u32;
    fn mask_count(self: @TContractState) -> u32;
    fn weapon_count(self: @TContractState) -> u32;
}


#[starknet::interface]
trait IDescriptorTokenMetadata<TContractState> {
    fn token_uri(self: @TContractState, token_id: u256, seed: Seed) -> ByteArray;
}



#[starknet::contract]
mod Descriptor {
    use core::array::ArrayTrait;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use blob::generation::{
        armour::{armours}, mask::{masks}, background::{backgrounds},
        jewellry::{jewellries}, weapon::{weapons}
    };

    use starknet::ContractAddress;
    use blob::seeder::Seed;
    use blob::generation::build::blobert;



    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl TraitsMetadata of super::IDescriptorTraitsMetadata<ContractState> {
        fn armour_count(self: @ContractState) -> u32 {
            return armours().len();
        }

        fn background_count(self: @ContractState) -> u32 {
            return backgrounds().len();
        }       

        fn jewellry_count(self: @ContractState) -> u32 {
            return jewellries().len();
        }

        fn mask_count(self: @ContractState) -> u32 {
            return masks().len();
        }

        fn weapon_count(self: @ContractState) -> u32 {
            return weapons().len();
        }
    }



    #[abi(embed_v0)]
    impl TokenMetadata of super::IDescriptorTokenMetadata<ContractState> {
        fn token_uri(self: @ContractState, token_id: u256, seed: Seed) -> ByteArray {
            blobert(token_id, seed)
        }
    }

}