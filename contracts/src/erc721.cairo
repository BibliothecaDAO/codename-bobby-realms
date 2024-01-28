use starknet::ContractAddress;
    

#[starknet::interface]
trait IERC721Metadata<TState> {
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
}

#[starknet::interface]
trait IERC721MetadataCamelOnly<TState> {
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;
}

#[starknet::interface]
trait BlobertTrait<TContractState> {

    fn mint(ref self: TContractState, recipient: ContractAddress);
    fn update_seeder(ref self: TContractState, seeder: ContractAddress);
    fn update_descriptor(ref self: TContractState, descriptor: ContractAddress);
}


#[starknet::contract]
mod BlobertNFT {
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use super::{IERC721Metadata, IERC721MetadataCamelOnly};
    use openzeppelin::access::ownable::OwnableComponent;

    use starknet::ContractAddress;
    use blob::seeder::{Seed, ISeederDispatcher, ISeederDispatcherTrait};
    use blob::descriptor::{IDescriptorDispatcher, IDescriptorDispatcherTrait};
    
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);


    // Ownable
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // ERC721
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;

    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;


    #[storage]
    struct Storage {
        current_token_id: u256,
        seeds: LegacyMap<u256, Seed>,
        seeder: ISeederDispatcher,
        descriptor: IDescriptorDispatcher,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,

    }


    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        owner: ContractAddress,
        seeder: ContractAddress,
        descriptor: ContractAddress
    ) {
        self.ownable.initializer(owner);
        self.erc721.initializer(name, symbol);
        self.initialize(seeder, descriptor);
    }


    #[abi(embed_v0)]
    impl ERC721Metadata of IERC721Metadata<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.erc721.ERC721_name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.erc721.ERC721_symbol.read()
        }

        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            assert(self.erc721._exists(token_id), ERC721Component::Errors::INVALID_TOKEN_ID);

            let descriptor = self.descriptor.read();
            let seed = self.seeds.read(token_id);
            return descriptor.token_uri(token_id, seed);
        }
    }


    #[abi(embed_v0)]
    impl ERC721MetadataCamelOnly of IERC721MetadataCamelOnly<ContractState> {
        fn tokenURI(self: @ContractState, tokenId: u256) -> ByteArray {
            self.token_uri(tokenId)
        }
    }


    #[abi(embed_v0)]
    impl BlobertImpl of super::BlobertTrait<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress ){

            // update token counter
            let token_id = self.current_token_id.read() + 1;
            self.current_token_id.write(token_id);

            // todo: check if recepient is in merkle tree
            // todo: collect payment from recipient

            self.erc721._mint(recipient, token_id);

            // set the token's seed
            let seeder = self.seeder.read();
            let descriptor = self.descriptor.read();
            let seed: Seed = seeder.generate_seed(
                    token_id, descriptor.contract_address
                );
            self.seeds.write(token_id, seed);

            //todo@credence ensure that seed is unique
            
        }

        fn update_seeder(ref self: ContractState, seeder: ContractAddress) {
            self.ownable.assert_only_owner();
            self._update_seeder(seeder);
        }

        fn update_descriptor(ref self: ContractState, descriptor: ContractAddress) {
            self.ownable.assert_only_owner();
            self._update_descriptor(descriptor);
        }
    }


    #[generate_trait]
    impl Internal of InternalTrait {
        fn initialize(
            ref self: ContractState, seeder: ContractAddress, descriptor: ContractAddress
        ) {
            self._update_seeder(seeder);
            self._update_descriptor(descriptor);
        }


        fn _update_seeder(ref self: ContractState, seeder: ContractAddress) {
            assert!(seeder != Zeroable::zero(), "Blobert: Seeder address cannot be zero");
            self.seeder.write(ISeederDispatcher{contract_address: seeder});
        }


        fn _update_descriptor(ref self: ContractState, descriptor: ContractAddress) {
            assert!(descriptor != Zeroable::zero(), "Blobert: Descriptor address cannot be zero");
            self.descriptor.write(IDescriptorDispatcher{contract_address: descriptor});
        }
        
    }

   
}