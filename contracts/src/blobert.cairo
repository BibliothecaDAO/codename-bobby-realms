use blob::types::blobert::MintStartTime;
use blob::types::blobert::Supply;
use blob::types::blobert::TokenTrait;
use blob::types::blobert::WhitelistTier;
use blob::types::seeder::Seed;
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
trait IBlobert<TContractState> {
    // contract state read
    fn supply(self: @TContractState) -> Supply;
    fn max_supply(self: @TContractState) -> u16;
    fn whitelist_mint_count(self: @TContractState, address: ContractAddress) -> u8;
    fn regular_mint_count(self: @TContractState, address: ContractAddress) -> u8;
    fn content_uri(self: @TContractState, token_id: u256) -> ByteArray;
    fn traits(self: @TContractState, token_id: u256) -> TokenTrait;
    fn svg_image(self: @TContractState, token_id: u256) -> ByteArray;

    fn seeder(self: @TContractState) -> ContractAddress;
    fn descriptor_regular(self: @TContractState) -> ContractAddress;
    fn descriptor_custom(self: @TContractState) -> ContractAddress;
    fn mint_time(self: @TContractState) -> MintStartTime;


    // contract state write
    fn mint(ref self: TContractState, recipient: ContractAddress) -> u256;
    fn mint_whitelist(
        ref self: TContractState,
        recipient: ContractAddress,
        merkle_proof: Span<felt252>,
        whitelist_tier: WhitelistTier
    ) -> u256;
    fn owner_assign_custom(ref self: TContractState, recipients: Span<ContractAddress>);
    fn owner_change_descriptor_regular(ref self: TContractState, descriptor: ContractAddress);
    fn owner_change_descriptor_custom(ref self: TContractState, descriptor: ContractAddress);
}


#[starknet::contract]
mod Blobert {
    use alexandria_merkle_tree::merkle_tree::{
        Hasher, MerkleTree, poseidon::PoseidonHasherImpl, MerkleTreeTrait, HasherTrait,
        MerkleTreeImpl
    };
    use blob::blobert::IBlobert;
    use blob::descriptor::descriptor_custom::{
        IDescriptorCustomDispatcher, IDescriptorCustomDispatcherTrait
    };

    use blob::descriptor::descriptor_regular::{
        IDescriptorRegularDispatcher, IDescriptorRegularDispatcherTrait
    };
    use blob::seeder::{Seed, ISeederDispatcher, ISeederDispatcherTrait};
    use blob::types::blobert::MintStartTime;
    use blob::types::blobert::Supply;
    use blob::types::blobert::TokenTrait;
    use blob::types::blobert::WhitelistTier;
    use blob::utils::randomness as rand;

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
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
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


    const MAX_SUPPLY: u16 = 4844;
    const MAX_CUSTOM_SUPPLY: u8 = 48;

    const FEE_RECIPIENT_ADDRESS: felt252 =
        0x0140809B710276e2e07c06278DD8f7D4a2528acE2764Fce32200852CB3893e5C;

    const MAX_REGULAR_MINT: u8 = 10; // max num of times `mint` can be called by an address

    const WHITELIST_TIER_COUNT: u8 = 4;

    const MAX_MINT_WHITELIST_TIER_1: u8 = 5;
    const MAX_MINT_WHITELIST_TIER_2: u8 = 3;
    const MAX_MINT_WHITELIST_TIER_3: u8 = 2;
    const MAX_MINT_WHITELIST_TIER_4: u8 = 1;

    // define weights for custom token lottery
    // minter is 300 times more likely to lose than win
    const WIN_CUSTOM_TOKEN_DRAW_WEIGHT: u128 = 1;
    const LOSE_CUSTOM_TOKEN_DRAW_WEIGHT: u128 = 300;


    mod Errors {
        const ZERO_OWNER: felt252 = 'Blobert: Owner is zero address';
        const ZERO_FEE_TOKEN_ADDRESS: felt252 = 'Blobert: fee token addr is 0';
        const ZERO_FEE_TOKEN_AMOUNT: felt252 = 'Blobert: fee token amount is 0';
        const WHITELIST_MINT_START_TIME_NOT_FUTURE: felt252 = 'Blobert: time whtlst not future';
        const REGULAR_MINT_START_TIME_BEFORE_WHITELIST_END: felt252 =
            'Blobert: time reg less whitelst';
        const INCORRECT_MERKLE_ROOT_COUNT: felt252 = 'Blobert: should have 5 roots';
        const ZERO_MERKLE_ROOT: felt252 = 'Blobert: no merkle root';
        const INSUFFICIENT_FUND: felt252 = 'Blobert: insufficient fund';
        const INSUFFICIENT_APPROVAL: felt252 = 'Blobert: insufficient approval';
        const BEFORE_WHITELIST_MINT: felt252 = 'Blobert: whtelst mint not begun';
        const AFTER_WHITELIST_MINT: felt252 = 'Blobert: whitelist mint ended';
        const BEFORE_REGULAR_MINT: felt252 = 'Blobert: reg mint not started';
        const MULTICALL_NOT_ALLOWED: felt252 = 'Blobert: no multicall';
        const NOT_IN_MERKLE_TREE: felt252 = 'Blobert: not in merkletree';
        const ZERO_ADDRESS_SEEDER: felt252 = 'Blobert: zero addr seeder';
        const ZERO_ADDRESS_DESCRIPTOR: felt252 = 'Blobert: zero addr descriptor';
        const ONE_TIME_CALL_ONLY: felt252 = 'Blobert: cant be called twice';
        const MAX_SUPPLY_EXCEEDED: felt252 = 'Blobert: max supply exceeded';
        const MAX_MINT_EXCEEDED: felt252 = 'Blobert: maxed wallet mint';
    }


    #[storage]
    struct Storage {
        //
        supply: Supply,
        custom_image_counts: LegacyMap<u16, u8>, // map of nft id to custom image count
        //
        merkle_root_tier_1_whitelist: felt252,
        merkle_root_tier_2_whitelist: felt252,
        merkle_root_tier_3_whitelist: felt252,
        merkle_root_tier_4_whitelist: felt252,
        //
        num_whitelist_mints: LegacyMap<ContractAddress, u8>, // num whitelist mints per address
        num_regular_mints: LegacyMap<ContractAddress, u8>, // num regular mints per address
        //
        regular_nft_seeds: LegacyMap<u256, Seed>,
        regular_nft_exists: LegacyMap<felt252, bool>,
        regular_nft_seeder: ISeederDispatcher,
        //
        descriptor_custom: IDescriptorCustomDispatcher,
        descriptor_regular: IDescriptorRegularDispatcher,
        //
        mint_start_time: MintStartTime,
        //
        fee_token_address: ContractAddress,
        fee_token_amount: u256,
        //
        multicall_tracker: LegacyMap<ContractAddress, felt252>,
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
        regular_nft_seeder: ContractAddress,
        descriptor_regular: ContractAddress,
        descriptor_custom: ContractAddress,
        fee_token_address: ContractAddress,
        fee_token_amount: u256,
        merkle_roots: Span<felt252>,
        mint_start_time: MintStartTime,
        initial_custom_nft_recipients: Span<ContractAddress>
    ) {
        // initialize ownable
        assert(owner != Zeroable::zero(), Errors::ZERO_OWNER);
        self.ownable.initializer(owner);

        // initialize erc721 
        self.erc721.initializer(name, symbol);

        // initialize contract
        self
            .initialize(
                :regular_nft_seeder,
                :descriptor_regular,
                :descriptor_custom,
                :fee_token_address,
                :fee_token_amount,
                :merkle_roots,
                :mint_start_time,
                :initial_custom_nft_recipients
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
            let traits = self.traits(token_id);
            match traits {
                TokenTrait::Regular(seed) => {
                    self.descriptor_regular.read().token_uri(token_id, seed)
                },
                TokenTrait::Custom(index) => {
                    self.descriptor_custom.read().token_uri(token_id, index)
                }
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
    impl BlobertImpl of super::IBlobert<ContractState> {
        //
        // Contract read
        //

        fn supply(self: @ContractState) -> Supply {
            self.supply.read()
        }

        fn max_supply(self: @ContractState) -> u16 {
            MAX_SUPPLY
        }

        fn whitelist_mint_count(self: @ContractState, address: ContractAddress) -> u8 {
            self.num_whitelist_mints.read(
               address
            )
        }

        fn regular_mint_count(self: @ContractState, address: ContractAddress) -> u8 {
            self.num_regular_mints.read(
                address
            )
        }

        fn traits(self: @ContractState, token_id: u256) -> TokenTrait {
            assert(self.erc721._exists(token_id), ERC721Component::Errors::INVALID_TOKEN_ID);

            let custom_token_number = self.custom_image_counts.read(token_id.try_into().unwrap());
            if custom_token_number != 0 {
                let image_index = custom_token_number - 1;
                return TokenTrait::Custom(image_index);
            } else {
                let seed = self.regular_nft_seeds.read(token_id);
                return TokenTrait::Regular(seed);
            }
        }


        fn content_uri(self: @ContractState, token_id: u256) -> ByteArray {
            let traits = self.traits(token_id);
            match traits {
                TokenTrait::Regular(seed) => { self.descriptor_regular.read().content_uri(token_id, seed) },
                TokenTrait::Custom(index) => { self.descriptor_custom.read().content_uri(token_id, index) }
            }
        }



        fn svg_image(self: @ContractState, token_id: u256) -> ByteArray {
            let traits = self.traits(token_id);
            match traits {
                TokenTrait::Regular(seed) => { self.descriptor_regular.read().svg_image(seed) },
                TokenTrait::Custom(index) => { self.descriptor_custom.read().svg_image(index) }
            }
        }


        fn seeder(self: @ContractState) -> ContractAddress {
            self.regular_nft_seeder.read().contract_address
        }

        fn descriptor_regular(self: @ContractState) -> ContractAddress {
            self.descriptor_regular.read().contract_address
        }

        fn descriptor_custom(self: @ContractState) -> ContractAddress {
            self.descriptor_custom.read().contract_address
        }

        fn mint_time(self: @ContractState) -> MintStartTime {
            self.mint_start_time.read()
        }


        //
        // Contract write
        //

        fn mint(ref self: ContractState, recipient: ContractAddress) -> u256 {
            // ensure this function can only be called once per transaction
            self.ensure_one_call_per_tx();

            // ensure that its time for regular mint
            self.ensure_regular_mint_period();

            // ensure that caller address has not max minted
            let caller = starknet::get_caller_address();
            let num_regular_mint = self.num_regular_mints.read(caller);
            assert(num_regular_mint < MAX_REGULAR_MINT.into(), Errors::MAX_MINT_EXCEEDED);
            // update caller's regular mint count 
            self.num_regular_mints.write(caller, num_regular_mint + 1);

            // get next token id and update supply
            let mut supply = self.supply.read();
            supply.total_nft += 1;
            self.supply.write(supply);

            let token_id: u16 = supply.total_nft;

            // mint token to recipient and collect fee
            self.mint_token(:token_id, :caller, :recipient, collect_fee: true);

            if self.caller_won_custom_token() {
                self.set_custom_image(token_id);
            } else {
                self.set_regular_image(token_id);
            }

            token_id.into()
        }


        fn mint_whitelist(
            ref self: ContractState,
            recipient: ContractAddress,
            merkle_proof: Span<felt252>,
            whitelist_tier: WhitelistTier
        ) -> u256 {
            // ensure that its period for whitelist mint
            self.ensure_whitelist_mint_period();

            // @note we assume that none of the lists would contain the same address
            // so we can use the same balances map for all whitelist tiers

            // ensure that address has not reached whitelist mint allowance 
            let (merkle_root, max_whitelist_allowance) = self.tier_merkle_root(whitelist_tier);
            let caller = starknet::get_caller_address();
            let num_whitelist_mint = self.num_whitelist_mints.read(caller);
            assert(num_whitelist_mint < max_whitelist_allowance, Errors::MAX_MINT_EXCEEDED);
            // update caller's whitelist mint count 
            self.num_whitelist_mints.write(caller, num_whitelist_mint + 1);

            // verify merkle proof
            self.ensure_valid_merkle_proof(caller, :merkle_proof, :merkle_root);

            // get next token id and update supply
            let mut supply = self.supply.read();
            supply.total_nft += 1;
            self.supply.write(supply);

            let token_id: u16 = supply.total_nft;

            // mint token to recipient at no cost
            self.mint_token(:token_id, :caller, :recipient, collect_fee: false);
            self.set_regular_image(token_id);

            token_id.into()
        }


        fn owner_assign_custom(ref self: ContractState, mut recipients: Span<ContractAddress>) {
            self.ownable.assert_only_owner();
            self.assign_custom(recipients);
        }


        fn owner_change_descriptor_regular(ref self: ContractState, descriptor: ContractAddress) {
            self.ownable.assert_only_owner();
            self.set_descriptor_regular(descriptor);
        }

        fn owner_change_descriptor_custom(ref self: ContractState, descriptor: ContractAddress) {
            self.ownable.assert_only_owner();
            self.set_descriptor_custom(descriptor);
        }
    }


    #[generate_trait]
    impl Internal of InternalTrait {
        fn initialize(
            ref self: ContractState,
            regular_nft_seeder: ContractAddress,
            descriptor_regular: ContractAddress,
            descriptor_custom: ContractAddress,
            fee_token_address: ContractAddress,
            fee_token_amount: u256,
            merkle_roots: Span<felt252>,
            mint_start_time: MintStartTime,
            initial_custom_nft_recipients: Span<ContractAddress>
        ) {
            assert(
                initial_custom_nft_recipients.len() <= MAX_CUSTOM_SUPPLY.into(),
                Errors::MAX_SUPPLY_EXCEEDED
            );
            self.assign_custom(initial_custom_nft_recipients);

            assert(
                mint_start_time.whitelist > starknet::get_block_timestamp(),
                Errors::WHITELIST_MINT_START_TIME_NOT_FUTURE
            );

            assert(
                mint_start_time.regular > mint_start_time.whitelist,
                Errors::REGULAR_MINT_START_TIME_BEFORE_WHITELIST_END
            );

            self.mint_start_time.write(mint_start_time);

            assert(
                merkle_roots.len() == WHITELIST_TIER_COUNT.into(),
                Errors::INCORRECT_MERKLE_ROOT_COUNT
            );

            let merkle_root_tier_1 = *merkle_roots.at(0);
            assert(merkle_root_tier_1 != 0, Errors::ZERO_MERKLE_ROOT);
            self.merkle_root_tier_1_whitelist.write(merkle_root_tier_1);

            let merkle_root_tier_2 = *merkle_roots.at(1);
            assert(merkle_root_tier_2 != 0, Errors::ZERO_MERKLE_ROOT);
            self.merkle_root_tier_2_whitelist.write(merkle_root_tier_2);

            let merkle_root_tier_3 = *merkle_roots.at(2);
            assert(merkle_root_tier_3 != 0, Errors::ZERO_MERKLE_ROOT);
            self.merkle_root_tier_3_whitelist.write(merkle_root_tier_3);

            let merkle_root_tier_4 = *merkle_roots.at(3);
            assert(merkle_root_tier_4 != 0, Errors::ZERO_MERKLE_ROOT);
            self.merkle_root_tier_4_whitelist.write(merkle_root_tier_4);

            assert(fee_token_address != Zeroable::zero(), Errors::ZERO_FEE_TOKEN_ADDRESS);
            assert(fee_token_amount != 0, Errors::ZERO_FEE_TOKEN_AMOUNT);
            self.fee_token_address.write(fee_token_address);
            self.fee_token_amount.write(fee_token_amount);

            self.set_regular_nft_seeder(regular_nft_seeder);
            self.set_descriptor_regular(descriptor_regular);
            self.set_descriptor_custom(descriptor_custom);
        }


        fn assign_custom(ref self: ContractState, mut recipients: Span<ContractAddress>) {
            let mut supply: Supply = self.supply.read();
            let recipients_len = recipients.len();

            // ensure recipients are not more than max custom nft supply
            assert(
                supply.custom_nft.into() + recipients.len() <= MAX_CUSTOM_SUPPLY.into(),
                Errors::MAX_SUPPLY_EXCEEDED
            );

            // mint custom nft to each recipient 
            let caller = starknet::get_caller_address();
            let mut count: u8 = 1;
            loop {
                match recipients.pop_front() {
                    Option::Some(recipient) => {
                        let recipient = *recipient;

                        // mint token to recipient at no cost
                        let token_id: u16 = supply.total_nft.into() + count.into();
                        self.mint_token(:token_id, :caller, :recipient, collect_fee: false);

                        // set custom token image
                        self.custom_image_counts.write(token_id, supply.custom_nft + count);

                        count += 1;
                    },
                    Option::None(()) => { break; }
                }
            };

            // increment token counters
            supply.total_nft += recipients_len.try_into().unwrap();
            supply.custom_nft += recipients_len.try_into().unwrap();
            self.supply.write(supply);
        }


        fn tier_merkle_root(ref self: ContractState, tier: WhitelistTier) -> (felt252, u8) {
            match tier {
                WhitelistTier::One => {
                    (self.merkle_root_tier_1_whitelist.read(), MAX_MINT_WHITELIST_TIER_1)
                },
                WhitelistTier::Two => {
                    (self.merkle_root_tier_2_whitelist.read(), MAX_MINT_WHITELIST_TIER_2)
                },
                WhitelistTier::Three => {
                    (self.merkle_root_tier_3_whitelist.read(), MAX_MINT_WHITELIST_TIER_3)
                },
                WhitelistTier::Four => {
                    (self.merkle_root_tier_4_whitelist.read(), MAX_MINT_WHITELIST_TIER_4)
                }
            }
        }


        // @note recipient is not necessarily caller. check for risks
        fn mint_token(
            ref self: ContractState,
            token_id: u16,
            caller: ContractAddress,
            recipient: ContractAddress,
            collect_fee: bool
        ) {
            // ensure that token count is less than or equal max supply
            assert(token_id <= self.max_supply(), Errors::MAX_SUPPLY_EXCEEDED);

            // type cast token_id
            let token_id: u256 = token_id.into();

            // mint token to recipient
            self.erc721._mint(recipient, token_id);

            // collect fees from caller if necessary
            if collect_fee {
                let fee_token = IERC20Dispatcher {
                    contract_address: self.fee_token_address.read()
                };
                let fee_amount = self.fee_token_amount.read();
                assert(fee_token.balance_of(caller) >= fee_amount, Errors::INSUFFICIENT_FUND);
                assert(
                    fee_token
                        .allowance(caller, starknet::get_contract_address()) >= fee_amount
                        .into(),
                    Errors::INSUFFICIENT_APPROVAL
                );

                fee_token
                    .transfer_from(caller, FEE_RECIPIENT_ADDRESS.try_into().unwrap(), fee_amount);
            }
        }


        fn caller_won_custom_token(ref self: ContractState) -> bool {
            let supply = self.supply.read();
            if supply.custom_nft >= MAX_CUSTOM_SUPPLY {
                return false;
            }

            let num_choices = 1; // only choose one from options below
            let (win, lose) = (true, false);
            let options = array![win, lose].span();
            let cumm_weights = array![
                WIN_CUSTOM_TOKEN_DRAW_WEIGHT,
                WIN_CUSTOM_TOKEN_DRAW_WEIGHT + LOSE_CUSTOM_TOKEN_DRAW_WEIGHT
            ]
                .span();
            let weights = array![].span(); // since cumm_weights has been defined              
            let choice = *rand::choices(options, weights, cumm_weights, num_choices, true)[0];
            return choice;
        }


        // @note MUST not be called with same token id
        fn set_regular_image(ref self: ContractState, token_id: u16) {
            let token_id: u256 = token_id.into();

            // set the token's seed
            let regular_nft_seeder = self.regular_nft_seeder.read();
            let descriptor_regular = self.descriptor_regular.read();

            // ensure that seed is unique by using a salt
            let mut salt = 0;
            loop {
                let seed: Seed = regular_nft_seeder
                    .generate_seed(token_id, descriptor_regular.contract_address, salt);

                // ensure that seed is unique by comparing the seed's hash
                // with the hashes of regular_nft_seeds of minted tokens
                let seed_hash: felt252 = PoseidonTrait::new().update_with(seed).finalize();
                if !self.regular_nft_exists.read(seed_hash) {
                    self.regular_nft_seeds.write(token_id, seed);
                    self.regular_nft_exists.write(seed_hash, true);
                    break;
                }

                salt += 1;
            };
        }


        fn set_custom_image(ref self: ContractState, token_id: u16) {
            // ensure that the current custom nft supply is not up 
            // to the max so that there is allowance for one more to be minted

            let mut supply = self.supply.read();

            assert(supply.custom_nft < MAX_CUSTOM_SUPPLY, Errors::MAX_SUPPLY_EXCEEDED);

            self.custom_image_counts.write(token_id, supply.custom_nft + 1);
            supply.custom_nft += 1;
            self.supply.write(supply);
        }


        fn ensure_whitelist_mint_period(ref self: ContractState) {
            let now = starknet::get_block_timestamp();

            let mint_start_time = self.mint_start_time.read();
            assert(now >= mint_start_time.whitelist, Errors::BEFORE_WHITELIST_MINT);
            assert(now < mint_start_time.regular, Errors::AFTER_WHITELIST_MINT);
        }


        fn ensure_regular_mint_period(ref self: ContractState) {
            let now = starknet::get_block_timestamp();
            let mint_start_time = self.mint_start_time.read();
            assert(now >= mint_start_time.regular, Errors::BEFORE_REGULAR_MINT);
        }


        fn ensure_one_call_per_tx(ref self: ContractState) {
            let tx_info = starknet::get_tx_info().unbox();
            let tx_hash = tx_info.transaction_hash;
            let tx_origin = tx_info.account_contract_address;
            assert(
                self.multicall_tracker.read(tx_origin) != tx_hash, Errors::MULTICALL_NOT_ALLOWED
            );
            self.multicall_tracker.write(tx_origin, tx_hash);
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
            let leaf = PoseidonTrait::new().update_with(address).finalize();
            let merkle_verified = MerkleTreeImpl::<
                _, PoseidonHasherImpl
            >::verify(ref merkle_tree, merkle_root, leaf, merkle_proof);

            assert(merkle_verified, Errors::NOT_IN_MERKLE_TREE);
        }


        fn set_regular_nft_seeder(ref self: ContractState, regular_nft_seeder: ContractAddress) {
            assert(regular_nft_seeder != Zeroable::zero(), Errors::ZERO_ADDRESS_SEEDER);
            self
                .regular_nft_seeder
                .write(ISeederDispatcher { contract_address: regular_nft_seeder });
        }

        fn set_descriptor_regular(ref self: ContractState, descriptor: ContractAddress) {
            assert(descriptor != Zeroable::zero(), Errors::ZERO_ADDRESS_DESCRIPTOR);
            self
                .descriptor_regular
                .write(IDescriptorRegularDispatcher { contract_address: descriptor });
        }

        fn set_descriptor_custom(ref self: ContractState, descriptor: ContractAddress) {
            assert(descriptor != Zeroable::zero(), Errors::ZERO_ADDRESS_DESCRIPTOR);
            self
                .descriptor_custom
                .write(IDescriptorCustomDispatcher { contract_address: descriptor });
        }
    }
}

