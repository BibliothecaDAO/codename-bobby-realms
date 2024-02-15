use blob::types::erc721::WhitelistClass;
use starknet::ContractAddress;

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
    fn mint(ref self: TContractState, recipient: ContractAddress) -> u256;
    fn whitelist_mint(
        ref self: TContractState,
        recipient: ContractAddress,
        merkle_proof: Span<felt252>,
        whitelist_class: WhitelistClass
    ) -> u256;

    fn special_assignment(ref self: TContractState, recipients: Span<(u8, ContractAddress)>);

    fn admin_update_seeder(ref self: TContractState, seeder: ContractAddress);
    fn admin_update_descriptor(ref self: TContractState, descriptor: ContractAddress);
}


#[starknet::contract]
mod BlobertNFT {
    use alexandria_merkle_tree::merkle_tree::{
        Hasher, MerkleTree, poseidon::PoseidonHasherImpl, MerkleTreeTrait, HasherTrait,
        MerkleTreeImpl
    };

    use blob::descriptor::{IDescriptorDispatcher, IDescriptorDispatcherTrait};
    use blob::seeder::{Seed, ISeederDispatcher, ISeederDispatcherTrait};
    use blob::types::erc721::WhitelistClass;

    use core::hash::{HashStateTrait, HashStateExTrait};
    use core::poseidon::PoseidonTrait;
    use core::traits::TryInto;

    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait as OwnableInternalTrait;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use openzeppelin::token::erc721::ERC721Component;

    use starknet::ContractAddress;
    use super::{IERC721Metadata, IERC721MetadataCamelOnly};


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


    const NUM_SPECIAL_TOKENS: u8 = 3;

    const FEE_RECIPIENT_ADDRESS: felt252 = 0xADD;
    const FEE_TOKEN_ADDRESS: felt252 = 0x1;
    const FEE_TOKEN_AMOUNT: u8 = 100;

    const MAX_MINT_REGULAR: u8 = 10;
    const MAX_MINT_WHITELIST_DEV: u8 = 2;
    const MAX_MINT_WHITELIST_REALM_HOLDER: u8 = 5;


    #[storage]
    struct Storage {
        tx_hash_tracker: LegacyMap<ContractAddress, felt252>,
        token_count: u16,
        dev_merkle_root: felt252,
        realm_holder_merkle_root: felt252,
        whitelist_mint_starts_at: u64,
        regular_mint_starts_at: u64,
        regular_mint_count: LegacyMap<ContractAddress, u8>,
        dev_whitelist_mint_count: LegacyMap<ContractAddress, u8>,
        realm_holder_whitelist_mint_count: LegacyMap<ContractAddress, u8>,
        seeds: LegacyMap<u256, Seed>,
        seed_exists: LegacyMap<felt252, bool>,
        seeder: ISeederDispatcher,
        descriptor: IDescriptorDispatcher,
        special_token_count: u8,
        special_token_map: LegacyMap<u16, u8>,
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
        whitelist_mint_starts_at: u64,
        regular_mint_starts_at: u64,
    ) {
        self.ownable.initializer(owner);
        self.erc721.initializer(name, symbol);
        self
            .initialize(
                :seeder,
                :descriptor,
                :dev_merkle_root,
                :realm_holder_merkle_root,
                :whitelist_mint_starts_at,
                :regular_mint_starts_at
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
            let special_token_number = self.special_token_map.read(token_id.try_into().unwrap());
            if special_token_number > 0 {
                return descriptor.token_uri_special(token_id, special_token_number - 1);
            } else {
                let seed = self.seeds.read(token_id);
                return descriptor.token_uri(token_id, seed);
            }
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
        fn mint(ref self: ContractState, recipient: ContractAddress) -> u256 {
            // ensure this function can only be called once per transaction
            self.ensure_one_call_per_tx();

            // ensure that its time for regular mint
            self.ensure_regular_mint_period();

            let caller = starknet::get_caller_address();

            // ensure that address has not max minted
            let regular_mint_count = self.regular_mint_count.read(caller);
            assert!(regular_mint_count < MAX_MINT_REGULAR, "blobert: max mint exceeded");

            // get next token id and increment counter
            let token_id: u16 = (self.token_count.read() + 1);
            self.token_count.write(token_id);

            // mint token to recipient and collect fee
            self._mint(:token_id, :caller, :recipient, collect_fee: true);

            let token_id: u256 = token_id.into();
            // set seed for image
            self._set_seed(token_id);

            token_id
        }


        fn whitelist_mint(
            ref self: ContractState,
            recipient: ContractAddress,
            merkle_proof: Span<felt252>,
            whitelist_class: WhitelistClass
        ) -> u256 {
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
                    assert!(
                        dev_whitelist_mint_count < MAX_MINT_WHITELIST_DEV,
                        "Blobert: max mint for address"
                    );

                    // return merkle root for whitelist class
                    self.dev_merkle_root.read()
                },
                WhitelistClass::RealmHolder(()) => {
                    // ensure that address has not max minted
                    let realm_holder_whitelist_mint_count = self
                        .realm_holder_whitelist_mint_count
                        .read(caller);
                    assert!(
                        realm_holder_whitelist_mint_count < MAX_MINT_WHITELIST_REALM_HOLDER,
                        "Blobert: max mint for address"
                    );

                    // return merkle root for whitelist class
                    self.realm_holder_merkle_root.read()
                },
            };

            // verify merkle proof
            self.ensure_valid_merkle_proof(caller, :merkle_proof, :merkle_root);

            // get next token id and increment counter
            let token_id: u16 = (self.token_count.read() + 1);
            self.token_count.write(token_id);

            // mint token to recipient at no cost
            self._mint(:token_id, :caller, :recipient, collect_fee: false);

            let token_id: u256 = token_id.into();

            // set seed for image
            self._set_seed(token_id);

            token_id
        }


        fn special_assignment(
            ref self: ContractState, mut recipients: Span<(u8, ContractAddress)>
        ) {
            self.ownable.assert_only_owner();

            // ensure this function can only be called once by admin
            let token_count: u16 = self.token_count.read();
            let special_token_count = self.special_token_count.read();
            assert!(token_count == 0, "token already minted");
            assert!(special_token_count == 0, "special tokens already assigned");

            let caller = starknet::get_caller_address();

            let mut count: u8 = 0;
            loop {
                match recipients.pop_front() {
                    Option::Some((
                        image_index, recipient
                    )) => {
                        // @note we assume that image_index will be sequencial 

                        let (image_index, recipient) = (*image_index, *recipient);

                        // mint token to recipient at no cost
                        let token_id: u16 = token_count + count.into() + 1;
                        self._mint(:token_id, :caller, :recipient, collect_fee: false);

                        // set special token image
                        assert!(image_index < NUM_SPECIAL_TOKENS, "max special tokens minted");
                        self.special_token_map.write(token_id, count + 1);

                        count += 1;
                    },
                    Option::None(()) => { break; }
                }
            };

            // increment token counters
            self.token_count.write(count.into());
            self.special_token_count.write(count);
        }


        fn admin_update_seeder(ref self: ContractState, seeder: ContractAddress) {
            self.ownable.assert_only_owner();
            self._update_seeder(seeder);
        }

        fn admin_update_descriptor(ref self: ContractState, descriptor: ContractAddress) {
            self.ownable.assert_only_owner();
            self._update_descriptor(descriptor);
        }
    }


    #[generate_trait]
    impl Internal of InternalTrait {
        fn initialize(
            ref self: ContractState,
            seeder: ContractAddress,
            descriptor: ContractAddress,
            dev_merkle_root: felt252,
            realm_holder_merkle_root: felt252,
            whitelist_mint_starts_at: u64,
            regular_mint_starts_at: u64
        ) {
            self._update_seeder(seeder);
            self._update_descriptor(descriptor);

            assert!(
                whitelist_mint_starts_at > starknet::get_block_timestamp(),
                "whitelist mint time is in past"
            );
            assert!(
                regular_mint_starts_at > whitelist_mint_starts_at,
                "regular mint time is <= whitelist time"
            );
            self.whitelist_mint_starts_at.write(whitelist_mint_starts_at);
            self.regular_mint_starts_at.write(regular_mint_starts_at);

            assert!(dev_merkle_root != 0, "no dev merkle root");
            assert!(realm_holder_merkle_root != 0, "no realm holder merkle root");
            self.dev_merkle_root.write(dev_merkle_root);
            self.realm_holder_merkle_root.write(realm_holder_merkle_root);
        }


        // @note recipient is not necessarily caller. check for risks
        fn _mint(
            ref self: ContractState,
            token_id: u16,
            caller: ContractAddress,
            recipient: ContractAddress,
            collect_fee: bool
        ) {
            // type cast token_id
            let token_id: u256 = token_id.into();

            // mint token to recipient
            self.erc721._mint(recipient, token_id);

            // collect fees from caller if necessary
            if collect_fee {
                let fee_token = IERC20Dispatcher {
                    contract_address: FEE_TOKEN_ADDRESS.try_into().unwrap()
                };
                fee_token
                    .transfer_from(
                        caller, FEE_RECIPIENT_ADDRESS.try_into().unwrap(), FEE_TOKEN_AMOUNT.into()
                    );
            }
        }


        fn _set_seed(ref self: ContractState, token_id: u256) {
            // todo@credence calculate prob of hash collision

            // set the token's seed
            let seeder = self.seeder.read();
            let descriptor = self.descriptor.read();

            // ensure that seed is unique by using a salt
            let mut salt = 0x74657874206d652062616279207844204063726564656e63653078;
            loop {
                let seed: Seed = seeder.generate_seed(token_id, descriptor.contract_address, salt);

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
            self: @ContractState,
            address: ContractAddress,
            merkle_proof: Span<felt252>,
            merkle_root: felt252
        ) {
            let mut merkle_tree: MerkleTree<Hasher> = MerkleTreeImpl::<
                _, PoseidonHasherImpl
            >::new();
            let merkle_verified = MerkleTreeImpl::<
                _, PoseidonHasherImpl
            >::verify(ref merkle_tree, merkle_root, address.into(), merkle_proof);

            assert!(merkle_verified, "Blobert: address not in merkle tree");
        }


        fn _update_seeder(ref self: ContractState, seeder: ContractAddress) {
            assert!(seeder != Zeroable::zero(), "Blobert: Seeder address cannot be zero");
            self.seeder.write(ISeederDispatcher { contract_address: seeder });
        }


        fn _update_descriptor(ref self: ContractState, descriptor: ContractAddress) {
            assert!(descriptor != Zeroable::zero(), "Blobert: Descriptor address cannot be zero");
            self.descriptor.write(IDescriptorDispatcher { contract_address: descriptor });
        }
    }
}

