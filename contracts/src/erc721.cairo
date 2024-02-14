use starknet::ContractAddress;
use blob::types::erc721::WhitelistClass;

//todo@credence add renounceOwnership function
// so that seeder and descriptor may not be updated
    
//todo: contract needs a way to transfer receipt
//todo: handle 1 of 1s

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
    fn whitelist_mint(ref self: TContractState, recipient: ContractAddress, merkle_proof: Span<felt252>, whitelist_class:WhitelistClass);
    fn update_seeder(ref self: TContractState, seeder: ContractAddress);
    fn update_descriptor(ref self: TContractState, descriptor: ContractAddress);
}


#[starknet::contract]
mod BlobertNFT {
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin::token::erc721::ERC721Component;
    use super::{IERC721Metadata, IERC721MetadataCamelOnly};
    use openzeppelin::access::ownable::OwnableComponent;

    use starknet::ContractAddress;

    use blob::seeder::{Seed, ISeederDispatcher, ISeederDispatcherTrait};
    use blob::descriptor::{IDescriptorDispatcher, IDescriptorDispatcherTrait};
    use blob::types::erc721::WhitelistClass;

    use alexandria_merkle_tree::merkle_tree::{ 
        Hasher, MerkleTree, poseidon::PoseidonHasherImpl,  MerkleTreeTrait, HasherTrait, MerkleTreeImpl
    };
    use core::poseidon::PoseidonTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};

    
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


    const MAX_MINT_REGULAR: u8 = 10;
    const MAX_MINT_WHITELIST_DEV: u8 = 2;
    const MAX_MINT_WHITELIST_REALM_HOLDER: u8 = 5;


    #[storage]
    struct Storage {
        tx_hash_tracker: LegacyMap<ContractAddress, felt252>,
        current_token_id: u256,
        dev_merkle_root: felt252,
        realm_holder_merkle_root: felt252,
        fee_token: IERC20Dispatcher,
        fee_amount: u128,

        whitelist_mint_starts_at: u64,
        regular_mint_starts_at: u64,

        regular_mint_count: LegacyMap<ContractAddress, u8>,
        dev_whitelist_mint_count: LegacyMap<ContractAddress, u8>,
        realm_holder_whitelist_mint_count: LegacyMap<ContractAddress, u8>,

        seeds: LegacyMap<u256, Seed>,
        seed_exists: LegacyMap<felt252, bool>,
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
        descriptor: ContractAddress,
        dev_merkle_root: felt252, 
        realm_holder_merkle_root: felt252,
        fee_token: ContractAddress,
        fee_amount: u128,
        whitelist_mint_starts_at: u64,
        regular_mint_starts_at: u64,
    ) {
        self.ownable.initializer(owner);
        self.erc721.initializer(name, symbol);
        self.initialize(
            :seeder, :descriptor, 
            :dev_merkle_root, :realm_holder_merkle_root, 
            :whitelist_mint_starts_at, :regular_mint_starts_at,
            :fee_token, :fee_amount
        );
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

        fn mint(ref self: ContractState, recipient: ContractAddress){

            // ensure this function can only be called once per transaction
            self.ensure_one_call_per_tx();

            // ensure that its time for regular mint
            self.ensure_regular_mint_period();

            let caller = starknet::get_caller_address();
            
             // ensure that address has not max minted
            let regular_mint_count = self.regular_mint_count.read(caller);
            assert!(regular_mint_count < MAX_MINT_REGULAR, "blobert: max mint exceeded");

            // mint token to recipient and collect fee
            self._mint(:caller, :recipient, collect_fee: true);
        }




        fn whitelist_mint(
            ref self: ContractState, recipient: ContractAddress,
            merkle_proof: Span<felt252>, whitelist_class:WhitelistClass ){

            // ensure this function can only be called once per transaction
            self.ensure_one_call_per_tx();

            // ensure that its period for whitelist mint
            self.ensure_whitelist_mint_period();

            let caller = starknet::get_caller_address();
            
            // @note we assume that none of the lists would contain the same address

            let merkle_root = match whitelist_class {
                WhitelistClass::Dev(()) => {

                    // ensure that address has not max minted
                    let dev_whitelist_mint_count = self.dev_whitelist_mint_count.read(caller);
                    assert!(dev_whitelist_mint_count < MAX_MINT_WHITELIST_DEV, "Blobert: max mint for address");

                    // return merkle root for whitelist class
                    self.dev_merkle_root.read()
                },

                WhitelistClass::RealmHolder(()) => {

                    // ensure that address has not max minted
                    let realm_holder_whitelist_mint_count 
                        = self.realm_holder_whitelist_mint_count.read(caller);
                    assert!(
                        realm_holder_whitelist_mint_count < MAX_MINT_WHITELIST_REALM_HOLDER,
                            "Blobert: max mint for address"
                    );

                    // return merkle root for whitelist class
                    self.realm_holder_merkle_root.read()
                },
            };

            // verify merkle proof
            self.ensure_valid_merkle_proof(
                caller, :merkle_proof, :merkle_root
            );

            // mint token to recipient at no cost
            self._mint(:caller, :recipient, collect_fee: false);
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
            ref self: ContractState, seeder: ContractAddress, descriptor: ContractAddress,
            dev_merkle_root: felt252, realm_holder_merkle_root: felt252, 
            whitelist_mint_starts_at : u64, regular_mint_starts_at: u64,
            fee_token: ContractAddress, fee_amount: u128
        ) {
            self._update_seeder(seeder);
            self._update_descriptor(descriptor);

            assert!(whitelist_mint_starts_at > starknet::get_block_timestamp(), "whitelist mint time is in past");
            assert!(regular_mint_starts_at > whitelist_mint_starts_at, "regular mint time is <= whitelist time");

            self.whitelist_mint_starts_at.write(whitelist_mint_starts_at);
            self.regular_mint_starts_at.write(regular_mint_starts_at);

            self.dev_merkle_root.write(dev_merkle_root);
            self.realm_holder_merkle_root.write(realm_holder_merkle_root);
            self.fee_token.write(IERC20Dispatcher{contract_address: fee_token});
            self.fee_amount.write(fee_amount);
        }



        // @note recipient is not necessarily caller. check for risks
        fn _mint(ref self: ContractState, caller: ContractAddress, recipient: ContractAddress, collect_fee: bool) -> u256 {

            // get next token id and increment counter
            let token_id = self.current_token_id.read() + 1;
            self.current_token_id.write(token_id);

            // mint token to recipient
            self.erc721._mint(recipient, token_id);

            // collect fees from caller if necessary
            if collect_fee {    
                let this = starknet::get_contract_address();
                let fee_token = self.fee_token.read();
                fee_token.transfer_from(
                    caller, this, self.fee_amount.read().into()
                );
            }

            // set token seed
            self._set_seed(token_id);

            token_id
        }



        fn _set_seed(ref self: ContractState, token_id: u256 ) {
            // todo@credence calculate prob of hash collision

            // set the token's seed
            let seeder = self.seeder.read();
            let descriptor = self.descriptor.read();
        

            // ensure that seed is unique by using a salt
            let mut salt = 0x74657874206d652062616279207844204063726564656e63653078; 
            loop {
                let seed: Seed = seeder.generate_seed(
                    token_id, descriptor.contract_address, salt
                );

                // ensure that seed is unique by comparing the seed's hash
                // with the hashes of seeds of minted tokens
                let seed_hash: felt252 = PoseidonTrait::new().update_with(seed).finalize();
                if !self.seed_exists.read(seed_hash) {
                    self.seeds.write(token_id, seed);
                    self.seed_exists.write(seed_hash, true);
                    break;
                }

                salt += 1;
            };
        }



        fn ensure_whitelist_mint_period(ref self: ContractState) {
            let now = starknet::get_block_timestamp();

            let whitelist_mint_starts_at = self.whitelist_mint_starts_at.read();
            assert!(now >= whitelist_mint_starts_at, "blobert: whitelist mint has not begun");

            //note. could probably store both in single storage slot
            let regular_mint_starts_at = self.regular_mint_starts_at.read();
            assert!(now < regular_mint_starts_at, "blobert: whitelist mint has ended");
        }


        fn ensure_regular_mint_period(ref self: ContractState) {
            let now = starknet::get_block_timestamp();
            let regular_mint_starts_at = self.regular_mint_starts_at.read();
            assert!(now >= regular_mint_starts_at, "blobert: whitelist mint has ended");
        }


        fn ensure_one_call_per_tx(ref self: ContractState) {
            let tx_info = starknet::get_tx_info().unbox();
            let tx_hash = tx_info.transaction_hash;
            let tx_origin = tx_info.account_contract_address;
            assert(self.tx_hash_tracker.read(tx_origin) != tx_hash, 'Multi calls not allowed');
            self.tx_hash_tracker.write(tx_origin, tx_hash);
        }

        fn ensure_valid_merkle_proof(
            self: @ContractState, address: ContractAddress, merkle_proof: Span<felt252>, merkle_root: felt252
            ){

            let mut merkle_tree: MerkleTree<Hasher> 
                = MerkleTreeImpl::<_, PoseidonHasherImpl>::new();
            let merkle_verified =  MerkleTreeImpl::<
                _, PoseidonHasherImpl
            >::verify(ref merkle_tree, merkle_root, address.into(), merkle_proof);

            assert!(merkle_verified, "Blobert: address not in merkle tree");
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