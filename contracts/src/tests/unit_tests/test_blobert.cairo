// todo@ add new internal tests

#[cfg(test)]
mod blobert_constructor_tests {
    use core::traits::TryInto;
    use blob::blobert::Blobert::__member_module_descriptor_regular::InternalContractMemberStateTrait as ___T;
    use blob::blobert::Blobert::__member_module_descriptor_custom::InternalContractMemberStateTrait as ___F;

    use blob::blobert::Blobert::__member_module_merkle_root_tier_1_whitelist::InternalContractMemberStateTrait as _A;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_2_whitelist::InternalContractMemberStateTrait as __B;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_3_whitelist::InternalContractMemberStateTrait as __V;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_4_whitelist::InternalContractMemberStateTrait as __F;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_5_whitelist::InternalContractMemberStateTrait as __E;
    use blob::blobert::Blobert::__member_module_mint_start_time::InternalContractMemberStateTrait as _____T;
    use blob::blobert::Blobert::__member_module_regular_nft_seeder::InternalContractMemberStateTrait as ____T;
    use blob::blobert::Blobert::__member_module_supply::InternalContractMemberStateTrait as ______T;
    use blob::blobert::Blobert::__member_module_fee_token_address::InternalContractMemberStateTrait as _DA;
    use blob::blobert::Blobert::__member_module_fee_token_amount::InternalContractMemberStateTrait as _AD;

    use blob::blobert::Blobert;
    use blob::tests::unit_tests::utils::{
        ERC721_NAME, ERC721_SYMBOL, OWNER, SEEDER, DESCRIPTOR_REGULAR, DESCRIPTOR_CUSTOM, MERKLE_ROOTS, MINT_START_TIME,
        _50_ONE_OF_ONE_RECIPIENTS, FEE_TOKEN_ADDRESS, FEE_TOKEN_AMOUNT
    };
    use openzeppelin::access::ownable::interface::IOwnable;
    use openzeppelin::token::erc721::interface::IERC721Metadata;

    use starknet::contract_address_const;


    #[test]
    fn test_constructor_f() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let seeder = SEEDER();
        let descriptor_regular = DESCRIPTOR_REGULAR();
        let descriptor_custom = DESCRIPTOR_CUSTOM();
        Blobert::constructor(
            ref contract_state,
            ERC721_NAME(),
            ERC721_SYMBOL(),
            OWNER(),
            seeder,
            descriptor_regular,
            descriptor_custom,
            FEE_TOKEN_ADDRESS.try_into().unwrap(),
            FEE_TOKEN_AMOUNT.into(),
            MERKLE_ROOTS(),
            MINT_START_TIME(),
            _50_ONE_OF_ONE_RECIPIENTS().span()
        );

        // ensure erc721 name and symbol name are correct
        assert(contract_state.erc721.name() == ERC721_NAME(), 'wrong erc721 name');
        assert(contract_state.erc721.symbol() == ERC721_SYMBOL(), 'wrong erc721 name');

        // ensure owner address is accurate
        assert(contract_state.ownable.owner() == OWNER(), 'wrong owner address');

        // ensure supply is correct
        assert(contract_state.supply.read().total_nft == 50, 'wrong total nft count');
        assert(contract_state.supply.read().custom_nft == 50, 'wrong custom nft count');

        // ensure seeder and descriptor are correct
        assert(
            contract_state.regular_nft_seeder.read().contract_address == seeder,
            'wrong seeder address'
        );
        assert(
            contract_state.descriptor_regular.read().contract_address == descriptor_regular,
            'wrong descriptor address'
        );

        assert(
            contract_state.descriptor_custom.read().contract_address == descriptor_custom,
            'wrong descriptor address'
        );

        // ensure mint time is accurate
        assert(contract_state.mint_start_time.read() == MINT_START_TIME(), 'wrong mint time');

        // ensure merkle roots are correct
        assert(
            contract_state.merkle_root_tier_1_whitelist.read() == *MERKLE_ROOTS()[0],
            'wrong tier 1 merkle root'
        );
        assert(
            contract_state.merkle_root_tier_2_whitelist.read() == *MERKLE_ROOTS()[1],
            'wrong tier 2 merkle root'
        );
        assert(
            contract_state.merkle_root_tier_3_whitelist.read() == *MERKLE_ROOTS()[2],
            'wrong tier 3 merkle root'
        );
        assert(
            contract_state.merkle_root_tier_4_whitelist.read() == *MERKLE_ROOTS()[3],
            'wrong tier 4 merkle root'
        );
        assert(
            contract_state.merkle_root_tier_5_whitelist.read() == *MERKLE_ROOTS()[4],
            'wrong tier 5 merkle root'
        );


        // ensure fee token address and amount are correct
        assert(contract_state.fee_token_address.read().into() == FEE_TOKEN_ADDRESS, 'wrong fee token address');
        assert(contract_state.fee_token_amount.read() == FEE_TOKEN_AMOUNT.into(), 'wrong fee token amount');
    }

    #[test]
    #[should_panic(expected: ('Blobert: Owner is zero address',))]
    fn test_constructor_owner_address_zero() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let owner = contract_address_const::<0>();
        Blobert::constructor(
            ref contract_state,
            ERC721_NAME(),
            ERC721_SYMBOL(),
            owner,
            SEEDER(),
            DESCRIPTOR_REGULAR(),
            DESCRIPTOR_CUSTOM(),
            FEE_TOKEN_ADDRESS.try_into().unwrap(),
            FEE_TOKEN_AMOUNT.into(),
            MERKLE_ROOTS(),
            MINT_START_TIME(),
            array![].span()
        );
    }
}


#[cfg(test)]
mod blobert_internal_tests {
    use blob::blobert::Blobert::InternalTrait;
    use blob::blobert::Blobert::__member_module_custom_image_counts::InternalContractMemberStateTrait as _H;
    use blob::blobert::Blobert::__member_module_descriptor_regular::InternalContractMemberStateTrait as _K;
    use blob::blobert::Blobert::__member_module_descriptor_custom::InternalContractMemberStateTrait as _C;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_1_whitelist::InternalContractMemberStateTrait as _A;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_2_whitelist::InternalContractMemberStateTrait as _B;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_3_whitelist::InternalContractMemberStateTrait as _J;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_4_whitelist::InternalContractMemberStateTrait as _Q;
    use blob::blobert::Blobert::__member_module_merkle_root_tier_5_whitelist::InternalContractMemberStateTrait as _P;
    use blob::blobert::Blobert::__member_module_mint_start_time::InternalContractMemberStateTrait as _E;
    use blob::blobert::Blobert::__member_module_regular_nft_exists::InternalContractMemberStateTrait as _G;
    use blob::blobert::Blobert::__member_module_regular_nft_seeder::InternalContractMemberStateTrait as _D;
    use blob::blobert::Blobert::__member_module_regular_nft_seeds::InternalContractMemberStateTrait as _F;
    use blob::blobert::Blobert::__member_module_supply::InternalContractMemberStateTrait as _I;
    use blob::blobert::Blobert::__member_module_fee_token_address::InternalContractMemberStateTrait as _DA;
    use blob::blobert::Blobert::__member_module_fee_token_amount::InternalContractMemberStateTrait as _AD;


    use blob::blobert::Blobert;
    use blob::seeder::ISeederDispatcherTrait;
    use blob::tests::unit_tests::utils::{
        SEEDER, DESCRIPTOR_REGULAR, DESCRIPTOR_CUSTOM, MERKLE_ROOTS, MINT_START_TIME, MINTER, MINTER_RECIPIENT,
        _50_ONE_OF_ONE_RECIPIENTS, FEE_TOKEN_ADDRESS, FEE_TOKEN_AMOUNT,
        deploy_fee_token, deploy_seeder, deploy_descriptor_regular, deploy_descriptor_custom,
        create_merkle_tree
    };
    use blob::types::erc721::WhitelistTier;

    use core::array::SpanTrait;
    use core::debug::PrintTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};
    use core::option::OptionTrait;
    use core::poseidon::{PoseidonTrait, poseidon_hash_span};
    use core::traits::TryInto;
    use openzeppelin::token::erc20::interface::IERC20DispatcherTrait;

    use openzeppelin::token::erc721::interface::IERC721;

    use snforge_std::{
        declare, ContractClassTrait, start_warp, start_prank, stop_prank, CheatTarget, start_spoof,
        TxInfoMock, TxInfoMockTrait
    };

    use starknet::contract_address_const;


    ////////////////////////////////////////////////////
    //                  INITIALIZE 
    ////////////////////////////////////////////////////

    #[test]
    fn test_initialize() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let seeder = SEEDER();
        let descriptor_regular = DESCRIPTOR_REGULAR();
        let descriptor_custom = DESCRIPTOR_CUSTOM();
        contract_state
            .initialize(
                seeder,
                descriptor_regular,
                descriptor_custom,
                FEE_TOKEN_ADDRESS.try_into().unwrap(),
                FEE_TOKEN_AMOUNT.into(),
                MERKLE_ROOTS(),
                MINT_START_TIME(),
                _50_ONE_OF_ONE_RECIPIENTS().span()
            );

        // ensure seeder and descriptor are correct
        assert(
            contract_state.regular_nft_seeder.read().contract_address == seeder,
            'wrong seeder address'
        );
        assert(
            contract_state.descriptor_regular.read().contract_address == descriptor_regular,
            'wrong descriptor ref address'
        );

        assert(
            contract_state.descriptor_custom.read().contract_address == descriptor_custom,
            'wrong descriptor cus address'
        );

        // ensure supply is correct
        assert(contract_state.supply.read().total_nft == 50, 'wrong total nft count');
        assert(contract_state.supply.read().custom_nft == 50, 'wrong custom nft count');

        // ensure mint time is accurate
        assert(contract_state.mint_start_time.read() == MINT_START_TIME(), 'wrong mint time');

        // ensure merkle roots are correct
        assert(
            contract_state.merkle_root_tier_1_whitelist.read() == *MERKLE_ROOTS()[0],
            'wrong tier 1 merkle root'
        );
        assert(
            contract_state.merkle_root_tier_2_whitelist.read() == *MERKLE_ROOTS()[1],
            'wrong tier 2 merkle root'
        );
        assert(
            contract_state.merkle_root_tier_3_whitelist.read() == *MERKLE_ROOTS()[2],
            'wrong tier 3 merkle root'
        );
        assert(
            contract_state.merkle_root_tier_4_whitelist.read() == *MERKLE_ROOTS()[3],
            'wrong tier 4 merkle root'
        );
        assert(
            contract_state.merkle_root_tier_5_whitelist.read() == *MERKLE_ROOTS()[4],
            'wrong tier 5 merkle root'
        );


        // ensure fee token address and amount are correct
        assert(contract_state.fee_token_address.read().into() == FEE_TOKEN_ADDRESS, 'wrong fee token address');
        assert(contract_state.fee_token_amount.read() == FEE_TOKEN_AMOUNT.into(), 'wrong fee token amount');

    }


    #[test]
    #[should_panic(expected: ('Blobert: time whtlst not future',))]
    fn test_initialize_whitelist_mint_start_time_not_in_future() {
        let mut contract_state = Blobert::contract_state_for_testing();

        // set current time to equal mint time
        let mint_start_time = MINT_START_TIME();
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.whitelist);
        
        contract_state
            .initialize(
                SEEDER(),
                DESCRIPTOR_REGULAR(), 
                DESCRIPTOR_CUSTOM(), 
                FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                FEE_TOKEN_AMOUNT.into(), 
                MERKLE_ROOTS(), 
                mint_start_time, array![].span()
        );
    }


    #[test]
    #[should_panic(expected: ('Blobert: time reg less whitelst',))]
    fn test_initialize_regular_mint_start_time_not_greater_than_whitelist() {
        let mut contract_state = Blobert::contract_state_for_testing();

        // set regualar mint time == whitelist mint time
        let mut mint_start_time = MINT_START_TIME();
        mint_start_time.regular = mint_start_time.whitelist;

        contract_state
            .initialize(
                SEEDER(),
                DESCRIPTOR_REGULAR(), 
                DESCRIPTOR_CUSTOM(), 
                FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                FEE_TOKEN_AMOUNT.into(), 
                MERKLE_ROOTS(), 
                mint_start_time, array![].span()
        );
    }


    #[test]
    #[should_panic(expected: ('Blobert: no merkle root',))]
    fn test_initialize_no_merkle_root_tier_1_whitelist() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state
            .initialize(
                SEEDER(),
                DESCRIPTOR_REGULAR(), 
                DESCRIPTOR_CUSTOM(), 
                FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                FEE_TOKEN_AMOUNT.into(), 
                array![0, 1, 1, 1, 1].span(),
                MINT_START_TIME(),
                array![].span()
            );
    }


    #[test]
    #[should_panic(expected: ('Blobert: no merkle root',))]
    fn test_initialize_no_merkle_root_tier_2_whitelist() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state
            .initialize(
                SEEDER(),
                DESCRIPTOR_REGULAR(), 
                DESCRIPTOR_CUSTOM(), 
                FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                FEE_TOKEN_AMOUNT.into(), 
                array![1, 0, 1, 1, 1].span(),
                MINT_START_TIME(),
                array![].span()
            );
    }


    #[test]
    #[should_panic(expected: ('Blobert: no merkle root',))]
    fn test_initialize_no_merkle_root_tier_3_whitelist() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state
            .initialize(
                SEEDER(),
                DESCRIPTOR_REGULAR(), 
                DESCRIPTOR_CUSTOM(), 
                FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                FEE_TOKEN_AMOUNT.into(), 
                array![1, 1, 0, 1, 1].span(),
                MINT_START_TIME(),
                array![].span()
            );
    }


    #[test]
    #[should_panic(expected: ('Blobert: no merkle root',))]
    fn test_initialize_no_merkle_root_tier_4_whitelist() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state
            .initialize(
                SEEDER(),
                DESCRIPTOR_REGULAR(), 
                DESCRIPTOR_CUSTOM(), 
                FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                FEE_TOKEN_AMOUNT.into(), 
                array![1, 1, 1, 0, 1].span(),
                MINT_START_TIME(),
                array![].span()
            );
    }


    #[test]
    #[should_panic(expected: ('Blobert: no merkle root',))]
    fn test_initialize_no_merkle_root_tier_5_whitelist() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state
            .initialize(
                SEEDER(),
                DESCRIPTOR_REGULAR(), 
                DESCRIPTOR_CUSTOM(), 
                FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                FEE_TOKEN_AMOUNT.into(), 
                array![1, 1, 1, 1, 0].span(),
                MINT_START_TIME(),
                array![].span()
            );
    }


    ////////////////////////////////////////////////////
    //          ASSIGN CUSTOM
    ////////////////////////////////////////////////////

    #[test]
    fn test_assign_custom() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let recipients = _50_ONE_OF_ONE_RECIPIENTS();
        contract_state.assign_custom(recipients.span());

        // ensure total supply is correcct
        assert(contract_state.supply.read().total_nft == 50, 'wrong total supply');
        assert(contract_state.supply.read().custom_nft == 50, 'wrong total supply');

        // ensure the right token was minted to each address
        let mut recipient_index_in_original_list: Array<u8> = array![4, 23, 14, 49];
        loop {
            match recipient_index_in_original_list.pop_front() {
                Option::Some(recipient_index) => {
                    let recipient_index = recipient_index.into();
                    let recipient_token_id = recipient_index + 1;
                    let recipient = *recipients[recipient_index];
                    assert(contract_state.balance_of(recipient) == 1, 'wrong balance');
                    assert(
                        contract_state.owner_of(recipient_token_id.into()) == recipient,
                        'wrong owner of'
                    );
                    assert(
                        contract_state
                            .custom_image_counts
                            .read(
                                recipient_token_id.try_into().unwrap()
                            ) == (recipient_index.try_into().unwrap() + 1),
                        'wrong custom nft id to supply'
                    );
                },
                Option::None => { break; }
            }
        }
    }

    #[test]
    fn test_assign_custom_twice() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let original_recipients = _50_ONE_OF_ONE_RECIPIENTS();
        let mut first_batch_recipients = _50_ONE_OF_ONE_RECIPIENTS();
        let mut second_batch_recipients = array![];

        // remove 4 recipients and add to second batch
        second_batch_recipients.append(first_batch_recipients.pop_front().unwrap());
        second_batch_recipients.append(first_batch_recipients.pop_front().unwrap());
        second_batch_recipients.append(first_batch_recipients.pop_front().unwrap());
        second_batch_recipients.append(first_batch_recipients.pop_front().unwrap());

        // assign first batch 
        contract_state.assign_custom(first_batch_recipients.span());
        // ensure total supply is correcct
        assert(contract_state.supply.read().total_nft == 46, 'wrong total supply (1)');
        assert(contract_state.supply.read().custom_nft == 46, 'wrong total supply (1)');

        // ensure the right token was minted to each address
        let mut recipient_index_in_original_list: Array<u8> = array![4, 23, 14, 49];
        let (mut contract_state, original_recipients) = loop {
            match recipient_index_in_original_list.pop_front() {
                Option::Some(recipient_index) => {
                    let recipient_index = recipient_index.into();
                    let recipient_token_id = recipient_index + 1 - 4;
                    let recipient = *original_recipients[recipient_index];
                    assert(contract_state.balance_of(recipient) == 1, 'wrong balance (1)');
                    assert(
                        contract_state.owner_of(recipient_token_id.into()) == recipient,
                        'wrong owner of (1)'
                    );
                    assert(
                        contract_state
                            .custom_image_counts
                            .read(
                                recipient_token_id.try_into().unwrap()
                            ) == (recipient_index.try_into().unwrap() + 1 - 4),
                        'wrong map to supply (1)'
                    );
                },
                Option::None => { break (contract_state, original_recipients); }
            }
        };

        // assign second batch 
        contract_state.assign_custom(second_batch_recipients.span());
        // ensure total supply is correcct
        assert(contract_state.supply.read().total_nft == 50, 'wrong total supply (2)');
        assert(contract_state.supply.read().custom_nft == 50, 'wrong total supply (2)');

        // ensure the right token was minted to each address
        let mut recipient_index_in_original_list: Array<u8> = array![0, 1, 2, 3];
        loop {
            match recipient_index_in_original_list.pop_front() {
                Option::Some(recipient_index) => {
                    let recipient_index = recipient_index.into();
                    let recipient_token_id = recipient_index + 1 + 46;
                    let recipient = *original_recipients[recipient_index];
                    assert(contract_state.balance_of(recipient) == 1, 'wrong balance (2)');
                    assert(
                        contract_state.owner_of(recipient_token_id.into()) == recipient,
                        'wrong owner of (2)'
                    );
                    assert(
                        contract_state
                            .custom_image_counts
                            .read(
                                recipient_token_id.try_into().unwrap()
                            ) == (recipient_index.try_into().unwrap() + 1 + 46),
                        'wrong custom map to supply (2)'
                    );
                },
                Option::None => { break; }
            }
        };
    }


    #[test]
    #[should_panic(expected: ('Blobert: max supply exceeded',))]
    fn test_assign_custom__recipients_greater_than_max() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let mut recipients = _50_ONE_OF_ONE_RECIPIENTS();
        recipients.append(contract_address_const::<1>());
        contract_state.assign_custom(recipients.span());
    }


    ////////////////////////////////////////////////////
    //                  MINT TOKEN
    ////////////////////////////////////////////////////

    #[test]
    fn test_mint_token_collect_fee() {
        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();

        // deploy fee token 
        let fee_token = deploy_fee_token(
            deploy_at: FEE_TOKEN_ADDRESS.try_into().unwrap(),
            supply: FEE_TOKEN_AMOUNT.into(),
            supply_recipient: minter
        );

        // ensure that the fee token address was successfully mocked
        assert(
            fee_token.contract_address == FEE_TOKEN_ADDRESS.try_into().unwrap(),
            'wrong fee token address'
        );
        let minter_initial_balance = fee_token.balance_of(minter);

        // minter approves x $lords to be spent by blobert nft
        start_prank(CheatTarget::One(fee_token.contract_address), minter);
        fee_token.approve(snforge_std::test_address(), FEE_TOKEN_AMOUNT.into());
        stop_prank(CheatTarget::One(fee_token.contract_address));

        let mut contract_state = Blobert::contract_state_for_testing();
        // set fee token and amount
        contract_state.fee_token_address.write(FEE_TOKEN_ADDRESS.try_into().unwrap());
        contract_state.fee_token_amount.write(FEE_TOKEN_AMOUNT.into());        

        // call blobert internal mint
        let token_id = 1;
        contract_state
            .mint_token(token_id, caller: minter, recipient: minter_recipient, collect_fee: true);

        // ensure token was minted to correct recipient
        assert(
            contract_state.erc721.owner_of(token_id.into()) == minter_recipient,
            'wrong recipient nft balance'
        );

        // ensure minter has accurate balance
        assert(
            fee_token.balance_of(minter) == minter_initial_balance
                - FEE_TOKEN_AMOUNT.into(),
            'wrong minter erc20 balance'
        );

        // ensure fee recipient has accurate balance
        assert(
            fee_token
                .balance_of(
                    Blobert::FEE_RECIPIENT_ADDRESS.try_into().unwrap()
                ) == FEE_TOKEN_AMOUNT
                .into(),
            'wrong minter balance'
        );

        // ensure minter's allowance was spent
        assert(
            fee_token.allowance(minter, snforge_std::test_address()) == 0, 'wrong allowance balance'
        )
    }


    #[test]
    #[should_panic(expected: ('Blobert: insufficient fund',))]
    fn test_mint_token_collect_fee_insuffifient_balance() {
        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();
        

        // deploy fee token 
        let _ = deploy_fee_token(
            deploy_at: FEE_TOKEN_ADDRESS.try_into().unwrap(),
            supply: 0, // mint nothing
            supply_recipient: minter
        );

        let mut contract_state = Blobert::contract_state_for_testing();
        // set fee token and amount
        contract_state.fee_token_address.write(FEE_TOKEN_ADDRESS.try_into().unwrap());
        contract_state.fee_token_amount.write(FEE_TOKEN_AMOUNT.into());


        // call blobert internal mint
        contract_state
            .mint_token(
                token_id: 1, caller: minter, recipient: minter_recipient, collect_fee: true
            );
    }


    #[test]
    #[should_panic(expected: ('Blobert: insufficient approval',))]
    fn test_mint_token_collect_fee_insuffifient_approval() {
        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();

        // deploy fee token 
        let _ = deploy_fee_token(
            deploy_at: FEE_TOKEN_ADDRESS.try_into().unwrap(),
            supply: FEE_TOKEN_AMOUNT.into(),
            supply_recipient: minter
        );

        let mut contract_state = Blobert::contract_state_for_testing();
        // set fee token and amount
        contract_state.fee_token_address.write(FEE_TOKEN_ADDRESS.try_into().unwrap());
        contract_state.fee_token_amount.write(FEE_TOKEN_AMOUNT.into());

        // call blobert internal mint
        contract_state
            .mint_token(
                token_id: 1, caller: minter, recipient: minter_recipient, collect_fee: true
            );
    }


    #[test]
    fn test_mint_token_no_collect_fee() {
        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();

        // call blobert internal mint
        let mut contract_state = Blobert::contract_state_for_testing();
        let token_id = 1;
        contract_state
            .mint_token(token_id, caller: minter, recipient: minter_recipient, collect_fee: false);

        // ensure token was minted to correct recipient
        assert(
            contract_state.erc721.owner_of(token_id.into()) == minter_recipient,
            'wrong recipient nft balance'
        );
    }

    ////////////////////////////////////////////////////
    //           TIER MERKLE ROOT
    ////////////////////////////////////////////////////

    #[test]
    fn test_tier_merkle_root() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let merkle_root_tier_1 = 'merkle_root_tier_1';
        let merkle_root_tier_2 = 'merkle_root_tier_2';
        let merkle_root_tier_3 = 'merkle_root_tier_3';
        let merkle_root_tier_4 = 'merkle_root_tier_4';
        let merkle_root_tier_5 = 'merkle_root_tier_5';
        contract_state.merkle_root_tier_1_whitelist.write(merkle_root_tier_1);
        contract_state.merkle_root_tier_2_whitelist.write(merkle_root_tier_2);
        contract_state.merkle_root_tier_3_whitelist.write(merkle_root_tier_3);
        contract_state.merkle_root_tier_4_whitelist.write(merkle_root_tier_4);
        contract_state.merkle_root_tier_5_whitelist.write(merkle_root_tier_5);

        let (response_merkle_root_tier_1, max_mint_tier_1) = contract_state
            .tier_merkle_root(WhitelistTier::One);
        let (response_merkle_root_tier_2, max_mint_tier_2) = contract_state
            .tier_merkle_root(WhitelistTier::Two);
        let (response_merkle_root_tier_3, max_mint_tier_3) = contract_state
            .tier_merkle_root(WhitelistTier::Three);
        let (response_merkle_root_tier_4, max_mint_tier_4) = contract_state
            .tier_merkle_root(WhitelistTier::Four);
        let (response_merkle_root_tier_5, max_mint_tier_5) = contract_state
            .tier_merkle_root(WhitelistTier::Five);

        assert(response_merkle_root_tier_1 == merkle_root_tier_1, 'wrong root 1');
        assert(max_mint_tier_1 == Blobert::MAX_MINT_WHITELIST_TIER_1, 'wrong allowance 1');

        assert(response_merkle_root_tier_2 == merkle_root_tier_2, 'wrong root 2');
        assert(max_mint_tier_2 == Blobert::MAX_MINT_WHITELIST_TIER_2, 'wrong allowance 2');

        assert(response_merkle_root_tier_3 == merkle_root_tier_3, 'wrong root 3');
        assert(max_mint_tier_3 == Blobert::MAX_MINT_WHITELIST_TIER_3, 'wrong allowance 3');

        assert(response_merkle_root_tier_4 == merkle_root_tier_4, 'wrong root 4');
        assert(max_mint_tier_4 == Blobert::MAX_MINT_WHITELIST_TIER_4, 'wrong allowance 4');

        assert(response_merkle_root_tier_5 == merkle_root_tier_5, 'wrong root 5');
        assert(max_mint_tier_5 == Blobert::MAX_MINT_WHITELIST_TIER_5, 'wrong allowance 5');
    }


    ////////////////////////////////////////////////////
    //                  CALLER WON LOTTERY
    ////////////////////////////////////////////////////

    #[test]
    fn test_caller_won_custom_token() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let mut win_count = 0;

        let num_runs = 2_500;
        let mut i = 0;

        loop {
            if i == num_runs {
                break;
            }

            // update timestamp to make outcome different
            start_warp(
                CheatTarget::One(starknet::get_contract_address()),
                i * 42311763005 // change this value to get different outcome
            );

            if contract_state.caller_won_custom_token() {
                win_count += 1;
            };

            i += 1;
        };

        // ensure that the win rate is +2 or -2 from the expected win count

        let expected_win_count = num_runs
            / Blobert::LOSE_CUSTOM_TOKEN_DRAW_WEIGHT.try_into().unwrap();
        if win_count < expected_win_count {
            if win_count < (expected_win_count - 2) {
                assert!(false, "probablity might be wrong. Try using different timestamp");
            }
        }

        if win_count > expected_win_count {
            if win_count > (expected_win_count + 2) {
                assert!(false, "probablity might be wrong. Try using different timestamp");
            }
        }
    }


    ////////////////////////////////////////////////////
    //                SET REGULAR IMAGE
    ////////////////////////////////////////////////////

    #[test]
    fn test_set_regular_image() {
        let mut contract_state = Blobert::contract_state_for_testing();

        // deploy and set seeder and descriptor contracts
        let seeder = deploy_seeder();
        let descriptor_regular = deploy_descriptor_regular();
        contract_state.regular_nft_seeder.write(seeder);
        contract_state.descriptor_regular.write(descriptor_regular);

        let token_id = 1;
        contract_state.set_regular_image(token_id);

        let seed = contract_state.regular_nft_seeds.read(token_id.into());
        assert!(seed.background != 0, "background not set");
        assert!(seed.armour != 0, "armour not set");
        assert!(seed.weapon != 0, "weapon not set");
        assert!(seed.mask != 0, "mask not set");
        assert!(seed.jewelry != 0, "jewelry not set");

        let seed_hash = poseidon::poseidon_hash_span(
            array![
                seed.background.into(),
                seed.armour.into(),
                seed.jewelry.into(),
                seed.mask.into(),
                seed.weapon.into()
            ]
                .span()
        );

        assert!(contract_state.regular_nft_exists.read(seed_hash), "seed not added");
    }


    #[test]
    fn test_set_regular_image_with_collision() {
        let mut contract_state = Blobert::contract_state_for_testing();

        // deploy and set seeder and descriptor contracts
        let seeder = deploy_seeder();
        let descriptor_regular = deploy_descriptor_regular();
        contract_state.regular_nft_seeder.write(seeder);
        contract_state.descriptor_regular.write(descriptor_regular);

        let token_id = 1;

        // make first seed exist
        let first_seed_salt = 0;
        let first_seed = seeder
            .generate_seed(token_id, descriptor_regular.contract_address, first_seed_salt);
        let first_seed_hash: felt252 = PoseidonTrait::new().update_with(first_seed).finalize();
        contract_state.regular_nft_exists.write(first_seed_hash, true);

        // generate another seed for same token id
        contract_state.set_regular_image(token_id.try_into().unwrap());

        let second_seed = contract_state.regular_nft_seeds.read(token_id);
        let second_seed_salt = first_seed_salt + 1;
        let expected_second_seed = seeder
            .generate_seed(token_id, descriptor_regular.contract_address, second_seed_salt);

        assert!(second_seed == expected_second_seed, "wrong second seed");
    }


    ////////////////////////////////////////////////////
    //                 SET CUSTOM IMAGE
    ////////////////////////////////////////////////////

    #[test]
    fn test_set_custom_image() {
        let mut contract_state = Blobert::contract_state_for_testing();

        // set custom token for token id 1
        contract_state.set_custom_image(1);

        assert!(
            contract_state.custom_image_counts.read(1) == 1,
            "wrong token count map value (1)"
        );

        assert!(contract_state.supply.read().custom_nft == 1, "wrong custom token count (1)");

        // set custom token for token id 2 and 3
        contract_state.set_custom_image(2);
        contract_state.set_custom_image(3);

        assert!(
            contract_state.custom_image_counts.read(2) == 2,
            "wrong token count map value (2)"
        );
        assert!(
            contract_state.custom_image_counts.read(3) == 3,
            "wrong token count map value (3)"
        );

        assert!(contract_state.supply.read().custom_nft == 3, "wrong custom token count (3)");
    }


    ////////////////////////////////////////////////////
    //          ENSURE WHITELIST MINT PERIOD
    ////////////////////////////////////////////////////

    #[test]
    fn test_ensure_whitelist_mint_period() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_start_time = MINT_START_TIME();
        //      set mint time
        // everything should be okay since now 
        // >= whitelist time and now < mint_start_time.regular
        contract_state.mint_start_time.write(mint_start_time);

        // set block.timestamp to be after whitelist time
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), mint_start_time.whitelist + 1
        );
        assert!(
            starknet::get_block_timestamp() > mint_start_time.whitelist, "timestamp not warpped"
        );
        assert!(
            starknet::get_block_timestamp() < mint_start_time.regular,
            "regular should be set to higher than block ts"
        );

        contract_state.ensure_whitelist_mint_period();
    }


    #[test]
    #[should_panic(expected: ('Blobert: whtelst mint not begun',))]
    fn test_ensure_whitelist_mint_period__before_mint_period() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_start_time = MINT_START_TIME();
        contract_state.mint_start_time.write(mint_start_time);

        // set block.timestamp to be before whitelist time
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), mint_start_time.whitelist - 1
        );

        contract_state.ensure_whitelist_mint_period();
    }


    #[test]
    #[should_panic(expected: ('Blobert: whitelist mint ended',))]
    fn test_ensure_whitelist_mint_period__after_mint_period() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_start_time = MINT_START_TIME();
        contract_state.mint_start_time.write(mint_start_time);

        // set block.timestamp to be time for regular mint
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.regular);

        contract_state.ensure_whitelist_mint_period();
    }


    ////////////////////////////////////////////////////
    //          ENSURE REGULAR MINT PERIOD
    ////////////////////////////////////////////////////

    #[test]
    fn test_ensure_regular_mint_period() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_start_time = MINT_START_TIME();
        contract_state.mint_start_time.write(mint_start_time);

        // set block.timestamp to be time regular mint
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.regular);

        // call ensure period
        contract_state.ensure_regular_mint_period();

        // set block.timestamp to be after regular mint time
        // since it has no end, this should work too
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.regular + 1);

        // call ensure period again
        contract_state.ensure_regular_mint_period();
    }


    #[test]
    #[should_panic(expected: ('Blobert: reg mint not started',))]
    fn test_ensure_regular_mint_period__before_mint_period() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_start_time = MINT_START_TIME();
        contract_state.mint_start_time.write(mint_start_time);

        // set block.timestamp to be before regular mint time
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.regular - 1);

        // call ensure period
        contract_state.ensure_regular_mint_period();
    }


    ////////////////////////////////////////////////////
    //          ENSURE ONE CALL PER TX
    ////////////////////////////////////////////////////

    #[test]
    fn test_ensure_one_call_per_tx__single_call() {
        // mock transaction hash so it isnt 0
        let mut tx_info = TxInfoMockTrait::default();
        tx_info.transaction_hash = Option::Some(1234);
        start_spoof(CheatTarget::One(starknet::get_contract_address()), tx_info);

        // ensure single call works
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.ensure_one_call_per_tx();
    }


    #[test]
    #[should_panic(expected: ('Blobert: no multicall',))]
    fn test_ensure_one_call_per_tx__multi_call() {
        // mock transaction hash so it isnt 0
        let mut tx_info = TxInfoMockTrait::default();
        tx_info.transaction_hash = Option::Some(1234);
        start_spoof(CheatTarget::One(starknet::get_contract_address()), tx_info);

        // ensure multicall fails
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.ensure_one_call_per_tx();
        contract_state.ensure_one_call_per_tx();
    }


    ////////////////////////////////////////////////////
    //          ENSURE VALID MERKLE TREE
    ////////////////////////////////////////////////////

    #[test]
    fn test_ensure_valid_merkle_tree() {
        let (merkle_proof, merkle_root) = create_merkle_tree(starknet::get_contract_address());

        // ensure call does not fail
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state
            .ensure_valid_merkle_proof(starknet::get_contract_address(), merkle_proof, merkle_root)
    }


    #[test]
    #[should_panic(expected: ('Blobert: not in merkletree',))]
    fn test_ensure_valid_merkle_tree__bad_proof() {
        let (mut merkle_proof, merkle_root) = create_merkle_tree(starknet::get_contract_address());

        // corrupt proof
        let _ = merkle_proof.pop_back();

        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state
            .ensure_valid_merkle_proof(starknet::get_contract_address(), merkle_proof, merkle_root)
    }


    #[test]
    #[should_panic(expected: ('Blobert: not in merkletree',))]
    fn test_ensure_valid_merkle_tree__bad_root() {
        let (merkle_proof, mut merkle_root) = create_merkle_tree(starknet::get_contract_address());

        // corrupt root
        merkle_root += 1;

        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state
            .ensure_valid_merkle_proof(starknet::get_contract_address(), merkle_proof, merkle_root)
    }


    ////////////////////////////////////////////////////
    //          SET SEEDER CONTRACT
    ////////////////////////////////////////////////////

    #[test]
    fn test_set_seeder() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.set_regular_nft_seeder(contract_address_const::<'seeder'>())
    }

    #[test]
    #[should_panic(expected: ('Blobert: zero addr seeder',))]
    fn test_set_seeder_zero() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.set_regular_nft_seeder(Zeroable::zero())
    }


    ////////////////////////////////////////////////////
    //          SET DESCRIPTOR CONTRACT
    ////////////////////////////////////////////////////

    #[test]
    fn test_set_descriptor_regular() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let addr = contract_address_const::<'descriptor_regular'>();
        contract_state.set_descriptor_regular(addr);
        assert(contract_state.descriptor_regular.read().contract_address ==  addr, 'wrong descriptor reg');
    }

    #[test]
    #[should_panic(expected: ('Blobert: zero addr descriptor',))]
    fn test_set_descriptor_regular_zero() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.set_descriptor_regular(Zeroable::zero())
    }

    #[test]
    fn test_set_descriptor_custom() {
        let mut contract_state = Blobert::contract_state_for_testing();
        let addr = contract_address_const::<'descriptor_custom'>();
        contract_state.set_descriptor_custom(addr);
        assert(contract_state.descriptor_custom.read().contract_address ==  addr, 'wrong descriptor custom');
    }

    #[test]
    #[should_panic(expected: ('Blobert: zero addr descriptor',))]
    fn test_set_descriptor_custom_zero() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.set_descriptor_custom(Zeroable::zero())
    }
}


#[cfg(test)]
mod blobert_write_endpoint_tests {
    use blob::blobert::Blobert::__member_module_custom_image_counts::InternalContractMemberStateTrait as _F;

    use blob::blobert::Blobert::__member_module_descriptor_regular::InternalContractMemberStateTrait;
    use blob::blobert::Blobert::__member_module_descriptor_custom::InternalContractMemberStateTrait as _OO;
    use blob::blobert::Blobert::__member_module_num_regular_mints::InternalContractMemberStateTrait as _H;
    use blob::blobert::Blobert::__member_module_num_whitelist_mints::InternalContractMemberStateTrait as _D;
    use blob::blobert::Blobert::__member_module_regular_nft_seeds::InternalContractMemberStateTrait as _G;

    use blob::blobert::Blobert::__member_module_supply::InternalContractMemberStateTrait as _A;


    use blob::blobert::Blobert;
    use blob::blobert::IBlobert;
    use blob::descriptor::descriptor_regular::IDescriptorRegularDispatcherTrait;
    use blob::descriptor::descriptor_custom::IDescriptorCustomDispatcherTrait;
    use blob::seeder::ISeederDispatcherTrait;
    use blob::tests::unit_tests::utils::{
        ERC721_NAME, ERC721_SYMBOL, OWNER, MINTER, MINTER_RECIPIENT, SEEDER, DESCRIPTOR_REGULAR, DESCRIPTOR_CUSTOM,
        MERKLE_ROOTS, MINT_START_TIME, _50_ONE_OF_ONE_RECIPIENTS, FEE_TOKEN_ADDRESS, FEE_TOKEN_AMOUNT, deploy_fee_token, deploy_seeder,
        deploy_descriptor_regular, deploy_descriptor_custom ,  create_merkle_tree
    };
    use blob::types::erc721::WhitelistTier;
    use core::array::ArrayTrait;
    use core::array::SpanTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use openzeppelin::token::erc20::interface::IERC20DispatcherTrait;

    use openzeppelin::token::erc721::interface::IERC721;


    use snforge_std::{
        declare, ContractClassTrait, start_warp, start_prank, stop_prank, CheatTarget, start_spoof,
        TxInfoMock, TxInfoMockTrait
    };
    use starknet::ContractAddress;

    use starknet::contract_address_const;


    fn call_constructor() -> Blobert::ContractState {
        let mut contract_state = Blobert::contract_state_for_testing();
        Blobert::constructor(
            ref contract_state,
            ERC721_NAME(),
            ERC721_SYMBOL(),
            OWNER(),
            SEEDER(),
            DESCRIPTOR_REGULAR(),
            DESCRIPTOR_CUSTOM(),
            FEE_TOKEN_ADDRESS.try_into().unwrap(),
            FEE_TOKEN_AMOUNT.into(),
            MERKLE_ROOTS(),
            MINT_START_TIME(),
            array![].span()
        );

        return contract_state;
    }

    ////////////////////////////////////////////////////
    //          CUSTOM NFT ASSIGN
    ////////////////////////////////////////////////////

    #[test]
    fn test_owner_assign_custom() {
        let mut contract_state = call_constructor();
        let this = starknet::get_contract_address();

        // make caller the admin
        start_prank(CheatTarget::One(this), OWNER());

        let recipients = _50_ONE_OF_ONE_RECIPIENTS();
        contract_state.owner_assign_custom(recipients.span());

        // ensure total supply is correcct
        assert(contract_state.supply.read().total_nft == 50, 'wrong total supply');
        assert(contract_state.supply.read().custom_nft == 50, 'wrong total supply');
    }


    #[test]
    #[should_panic(expected: ('Caller is not the owner',))]
    fn test_owner_assign_custom__caller_not_owner() {
        let mut contract_state = call_constructor();
        start_prank(
            CheatTarget::One(starknet::get_contract_address()), contract_address_const::<1>()
        );
        contract_state.owner_assign_custom(array![].span());
    }


    ////////////////////////////////////////////////////
    //                  MINT
    ////////////////////////////////////////////////////

    #[test]
    fn test_mint_regular() {
        let mut contract_state = call_constructor();

        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();

        // deploy fee token 
        let fee_token = deploy_fee_token(
            deploy_at: FEE_TOKEN_ADDRESS.try_into().unwrap(),
            supply: FEE_TOKEN_AMOUNT.into(),
            supply_recipient: minter
        );

        let minter_initial_balance = fee_token.balance_of(minter);

        // minter approves x $lords to be spent by blobert nft
        start_prank(CheatTarget::One(fee_token.contract_address), minter);
        fee_token.approve(snforge_std::test_address(), FEE_TOKEN_AMOUNT.into());
        stop_prank(CheatTarget::One(fee_token.contract_address));

        // mock transaction hash so it isnt 0
        let mut tx_info = TxInfoMockTrait::default();
        tx_info.transaction_hash = Option::Some(1234);
        start_spoof(CheatTarget::One(starknet::get_contract_address()), tx_info);

        // set current time to regular mint time
        let mint_start_time = MINT_START_TIME();
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.regular);
        
        // call minter calls blobert mint
        start_prank(CheatTarget::One(starknet::get_contract_address()), minter);
        let token_id = contract_state.mint(minter_recipient);
        stop_prank(CheatTarget::One(starknet::get_contract_address()));

        // ensure token id is correct
        assert(token_id == 1, 'wrong token id');

        // ensure token was minted to correct recipient
        assert(
            contract_state.erc721.owner_of(token_id) == minter_recipient,
            'wrong recipient nft balance'
        );

        // ensure token erc721 balance is correct
        assert(
            contract_state.erc721.balance_of(minter_recipient) == 1, 'wrong recipient nft balance'
        );

        // ensure minter has accurate balance
        assert(
            fee_token.balance_of(minter) == minter_initial_balance
                - FEE_TOKEN_AMOUNT.into(),
            'wrong minter erc20 balance'
        );

        // ensure fee recipient has accurate balance
        assert(
            fee_token
                .balance_of(
                    Blobert::FEE_RECIPIENT_ADDRESS.try_into().unwrap()
                ) == FEE_TOKEN_AMOUNT
                .into(),
            'wrong minter balance'
        );

        // ensure minter's allowance was spent
        assert(
            fee_token.allowance(minter, snforge_std::test_address()) == 0, 'wrong allowance balance'
        );

        // ensure nft supply and number of mints were updated
        assert(contract_state.num_regular_mints.read(minter) == 1, 'wrong num regular mints');

        assert(contract_state.supply.read().total_nft == 1, 'wrong num supply');

        // ensure regular image seed was set 
        let seed = contract_state.regular_nft_seeds.read(token_id);
        if seed.background == 0 {
            if seed.armour == 0 {
                if seed.jewelry == 0 {
                    assert(false, 'seed not set');
                }
            }
        }
    }


    #[test]
    #[should_panic(expected: ('Blobert: no multicall',))]
    fn test_mint_regular_no_multicall() {
        let mut contract_state = call_constructor();

        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();

        // deploy fee token 
        let fee_token = deploy_fee_token(
            deploy_at: FEE_TOKEN_ADDRESS.try_into().unwrap(),
            supply: FEE_TOKEN_AMOUNT.into(),
            supply_recipient: minter
        );

        // minter approves x $lords to be spent by blobert nft
        start_prank(CheatTarget::One(fee_token.contract_address), minter);
        fee_token.approve(snforge_std::test_address(), FEE_TOKEN_AMOUNT.into());
        stop_prank(CheatTarget::One(fee_token.contract_address));

        // mock transaction hash so it isnt 0
        let mut tx_info = TxInfoMockTrait::default();
        tx_info.transaction_hash = Option::Some(1234);
        start_spoof(CheatTarget::One(starknet::get_contract_address()), tx_info);

        // set current time to regular mint time
        let mint_start_time = MINT_START_TIME();
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.regular);

        // call minter calls blobert mint twice
        start_prank(CheatTarget::One(starknet::get_contract_address()), minter);
        contract_state.mint(minter_recipient);
        contract_state.mint(minter_recipient);
        stop_prank(CheatTarget::One(starknet::get_contract_address()));
    }


    #[test]
    #[should_panic(expected: ('Blobert: reg mint not started',))]
    fn test_mint_regular_outside_regular_mint_period() {
        let mut contract_state = call_constructor();

        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();

        // deploy fee token 
        let fee_token = deploy_fee_token(
            deploy_at: FEE_TOKEN_ADDRESS.try_into().unwrap(),
            supply: FEE_TOKEN_AMOUNT.into(),
            supply_recipient: minter
        );

        // minter approves x $lords to be spent by blobert nft
        start_prank(CheatTarget::One(fee_token.contract_address), minter);
        fee_token.approve(snforge_std::test_address(), FEE_TOKEN_AMOUNT.into());
        stop_prank(CheatTarget::One(fee_token.contract_address));

        // mock transaction hash so it isnt 0
        let mut tx_info = TxInfoMockTrait::default();
        tx_info.transaction_hash = Option::Some(1234);
        start_spoof(CheatTarget::One(starknet::get_contract_address()), tx_info);

        // set current time to before regular mint time
        let mint_start_time = MINT_START_TIME();
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.regular - 1);

        // call minter calls blobert mint
        start_prank(CheatTarget::One(starknet::get_contract_address()), minter);
        contract_state.mint(minter_recipient);
        stop_prank(CheatTarget::One(starknet::get_contract_address()));
    }


    #[test]
    #[should_panic(expected: ('Blobert: maxed wallet mint',))]
    fn test_mint_regular_max_mint() {
        let mut contract_state = call_constructor();

        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();

        // deploy fee token 
        let fee_token = deploy_fee_token(
            deploy_at: FEE_TOKEN_ADDRESS.try_into().unwrap(),
            supply: FEE_TOKEN_AMOUNT.into() * 3,
            supply_recipient: minter
        );

        // minter approves x $lords to be spent by blobert nft
        start_prank(CheatTarget::One(fee_token.contract_address), minter);
        fee_token.approve(snforge_std::test_address(), FEE_TOKEN_AMOUNT.into() * 3);
        stop_prank(CheatTarget::One(fee_token.contract_address));

        // mock transaction hash so it isnt 0
        let mut tx_info = TxInfoMockTrait::default();
        tx_info.transaction_hash = Option::Some(1234);
        start_spoof(CheatTarget::One(starknet::get_contract_address()), tx_info);

        // set current time to before regular mint time
        let mint_start_time = MINT_START_TIME();
        start_warp(CheatTarget::One(starknet::get_contract_address()), mint_start_time.regular);

        // preset minter's regular mint count
        contract_state.num_regular_mints.write(minter, Blobert::MAX_REGULAR_MINT - 1);

        // call minter calls blobert mint twice
        start_prank(CheatTarget::One(starknet::get_contract_address()), minter);
        contract_state.mint(minter_recipient);

        // change tx hash before second call
        tx_info.transaction_hash = Option::Some(8888);
        start_spoof(CheatTarget::One(starknet::get_contract_address()), tx_info);

        contract_state.mint(minter_recipient);
    }


    #[test]
    fn test_mint_custom() {
        let mut contract_state = call_constructor();

        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();

        // deploy fee token 
        let fee_token = deploy_fee_token(
            deploy_at: FEE_TOKEN_ADDRESS.try_into().unwrap(),
            supply: FEE_TOKEN_AMOUNT.into(),
            supply_recipient: minter
        );

        let minter_initial_balance = fee_token.balance_of(minter);

        // minter approves x $lords to be spent by blobert nft
        start_prank(CheatTarget::One(fee_token.contract_address), minter);
        fee_token.approve(snforge_std::test_address(), FEE_TOKEN_AMOUNT.into());
        stop_prank(CheatTarget::One(fee_token.contract_address));

        // 104848548726390 timestamp  with tx hash of 1234
        // allows you mint a custom token 
        let mut tx_info = TxInfoMockTrait::default();
        tx_info.transaction_hash = Option::Some(1234);
        start_spoof(CheatTarget::One(starknet::get_contract_address()), tx_info);
        start_warp(CheatTarget::One(starknet::get_contract_address()), 104848548726390);

        // call minter calls blobert mint
        start_prank(CheatTarget::One(starknet::get_contract_address()), minter);
        let token_id = contract_state.mint(minter_recipient);
        stop_prank(CheatTarget::One(starknet::get_contract_address()));

        // ensure token id is correct
        assert(token_id == 1, 'wrong token id');

        // ensure token was minted to correct recipient
        assert(
            contract_state.erc721.owner_of(token_id) == minter_recipient,
            'wrong recipient nft balance'
        );

        // ensure token erc721 balance is correct
        assert(
            contract_state.erc721.balance_of(minter_recipient) == 1, 'wrong recipient nft balance'
        );

        // ensure minter has accurate balance
        assert(
            fee_token.balance_of(minter) == minter_initial_balance
                - FEE_TOKEN_AMOUNT.into(),
            'wrong minter erc20 balance'
        );

        // ensure fee recipient has accurate balance
        assert(
            fee_token
                .balance_of(
                    Blobert::FEE_RECIPIENT_ADDRESS.try_into().unwrap()
                ) == FEE_TOKEN_AMOUNT
                .into(),
            'wrong minter balance'
        );

        // ensure minter's allowance was spent
        assert(
            fee_token.allowance(minter, snforge_std::test_address()) == 0, 'wrong allowance balance'
        );

        // ensure nft supply and number of mints were updated
        assert(contract_state.num_regular_mints.read(minter) == 1, 'wrong num regular mints');

        assert(contract_state.supply.read().total_nft == 1, 'wrong num supply');

        // ensure custom image index was set 
        let image_index = contract_state
            .custom_image_counts
            .read(token_id.try_into().unwrap())
            - 1;
        assert(image_index == 0, 'wrong image index');
        // ensure custom nft supply was set 
        let custom_nft_supply = contract_state.supply.read().custom_nft;
        assert(custom_nft_supply == 1, 'wrong custom supply');
    }


    ////////////////////////////////////////////////////
    //                  WHITELIST MINT
    ////////////////////////////////////////////////////

    #[test]
    fn test_mint_whitelist() {
        // add minter to merkle tree
        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();
        let (second_tier_merkle_proof, second_tier_merkle_root) = create_merkle_tree(minter);
        let whitelist_tier = WhitelistTier::Two;
        let merkle_roots = array![1, second_tier_merkle_root, 3, 4, 5].span();

        let mut contract_state = Blobert::contract_state_for_testing();
        Blobert::constructor(
            ref contract_state,
            ERC721_NAME(),
            ERC721_SYMBOL(),
            OWNER(),
            SEEDER(),
            DESCRIPTOR_REGULAR(),
            DESCRIPTOR_CUSTOM(),
            FEE_TOKEN_ADDRESS.try_into().unwrap(),
            FEE_TOKEN_AMOUNT.into(),
            merkle_roots,
            MINT_START_TIME(),
            array![].span()
        );

        // set current time to whitelist mint time
        let mint_start_time = MINT_START_TIME();
        let this = starknet::get_contract_address();
        start_warp(CheatTarget::One(this), mint_start_time.whitelist);

        start_prank(CheatTarget::One(this), minter);
        let mut i = 0;
        loop {
            if i == Blobert::MAX_MINT_WHITELIST_TIER_2 {
                break;
            }

            // whitelisted address calls mint
            let token_id = contract_state
                .mint_whitelist(minter_recipient, second_tier_merkle_proof, whitelist_tier);

            let total_supply = token_id;

            // ensure token id is correct
            assert(token_id == (i + 1).into(), 'wrong token id');

            // ensure token was minted to correct recipient
            assert(
                contract_state.erc721.owner_of(token_id) == minter_recipient,
                'wrong recipient nft balance'
            );

            // ensure token erc721 balance is correct
            assert(
                contract_state.erc721.balance_of(minter_recipient) == total_supply,
                'wrong recipient nft balance'
            );

            // ensure nft supply and number of mints were updated
            assert(
                contract_state.num_whitelist_mints.read(minter).into() == total_supply,
                'wrong num whitelist mints'
            );

            assert(
                contract_state.supply.read().total_nft.into() == total_supply, 'wrong num supply'
            );

            // ensure regular image seed was set 
            let seed = contract_state.regular_nft_seeds.read(token_id);
            if seed.background == 0 {
                if seed.armour == 0 {
                    if seed.jewelry == 0 {
                        assert(false, 'seed not set');
                    }
                }
            }

            i += 1;
        };
        stop_prank(CheatTarget::One(this));
    }


    #[test]
    #[should_panic(expected: ('Blobert: whtelst mint not begun',))]
    fn test_mint_whitelist__outside_whitelist_mint_period() {
        // add minter to merkle tree
        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();
        let mut contract_state = call_constructor();

        // set current time to before whitelist mint time
        let mint_start_time = MINT_START_TIME();
        let this = starknet::get_contract_address();
        start_warp(CheatTarget::One(this), mint_start_time.whitelist - 1);
        start_prank(CheatTarget::One(this), minter);
        contract_state.mint_whitelist(minter_recipient, array![].span(), WhitelistTier::One);
    }


    #[test]
    #[should_panic(expected: ('Blobert: maxed wallet mint',))]
    fn test_mint_whitelist__max_allowance_minted() {
        // add minter to merkle tree
        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();
        let (second_tier_merkle_proof, second_tier_merkle_root) = create_merkle_tree(minter);
        let whitelist_tier = WhitelistTier::Two;
        let merkle_roots = array![1, second_tier_merkle_root, 3, 4, 5].span();

        let mut contract_state = Blobert::contract_state_for_testing();
        Blobert::constructor(
            ref contract_state,
            ERC721_NAME(),
            ERC721_SYMBOL(),
            OWNER(),
            SEEDER(),
            DESCRIPTOR_REGULAR(),
            DESCRIPTOR_CUSTOM(),
            FEE_TOKEN_ADDRESS.try_into().unwrap(),
            FEE_TOKEN_AMOUNT.into(),
            merkle_roots,
            MINT_START_TIME(),
            array![].span()
        );

        // set current time to whitelist mint time
        let mint_start_time = MINT_START_TIME();
        let this = starknet::get_contract_address();
        start_warp(CheatTarget::One(this), mint_start_time.whitelist);

        start_prank(CheatTarget::One(this), minter);
        let mut i = 0;
        loop {
            // try to mint one more than allowed
            if i == Blobert::MAX_MINT_WHITELIST_TIER_2 + 1 {
                break;
            }

            // whitelisted address calls mint
            contract_state
                .mint_whitelist(minter_recipient, second_tier_merkle_proof, whitelist_tier);
            i += 1;
        };
    }


    #[test]
    #[should_panic(expected: ('Blobert: not in merkletree',))]
    fn test_mint_whitelist__bad_merkle_proof() {
        // add minter to merkle tree
        let minter = MINTER();
        let minter_recipient = MINTER_RECIPIENT();
        let (second_tier_merkle_proof, second_tier_merkle_root) = create_merkle_tree(minter);
        let whitelist_tier = WhitelistTier::Two;
        let merkle_roots = array![1, second_tier_merkle_root, 3, 4, 5].span();

        let mut contract_state = Blobert::contract_state_for_testing();
        Blobert::constructor(
            ref contract_state,
            ERC721_NAME(),
            ERC721_SYMBOL(),
            OWNER(),
            SEEDER(),
            DESCRIPTOR_REGULAR(),
            DESCRIPTOR_CUSTOM(),
            FEE_TOKEN_ADDRESS.try_into().unwrap(),
            FEE_TOKEN_AMOUNT.into(),
            merkle_roots,
            MINT_START_TIME(),
            array![].span()
        );

        // set current time to whitelist mint time
        let mint_start_time = MINT_START_TIME();
        let this = starknet::get_contract_address();
        start_warp(CheatTarget::One(this), mint_start_time.whitelist);

        // non whitelisted address calls mint
        start_prank(CheatTarget::One(this), contract_address_const::<'not whitelisted'>());
        contract_state.mint_whitelist(minter_recipient, second_tier_merkle_proof, whitelist_tier);
    }


    ////////////////////////////////////////////////////
    //          OWNER CHANGE DESCRIPTOR
    ////////////////////////////////////////////////////

    #[test]
    fn test_update_descriptor_regular() {
        let mut contract_state = call_constructor();

        // owner changes the descriptor
        start_prank(CheatTarget::One(starknet::get_contract_address()), OWNER());
        contract_state.owner_change_descriptor_regular(
            contract_address_const::<'new_descriptor'>()
        );

        assert(
            contract_state
                .descriptor_regular
                .read()
                .contract_address == contract_address_const::<'new_descriptor'>(),
            'wrong descriptor'
        );
    }

    #[test]
    #[should_panic(expected: ('Caller is not the owner',))]
    fn test_update_descriptor_regular__caller_not_owner() {
        let mut contract_state = call_constructor();

        // unknown address changes the descriptor
        start_prank(
            CheatTarget::One(starknet::get_contract_address()),
            contract_address_const::<'unknown_caller'>()
        );
        contract_state.owner_change_descriptor_regular(
            contract_address_const::<'new_descriptor'>()
        );
    }


    #[test]
    fn test_update_descriptor_custom() {
        let mut contract_state = call_constructor();

        // owner changes the descriptor
        start_prank(CheatTarget::One(starknet::get_contract_address()), OWNER());
        contract_state.owner_change_descriptor_custom(
            contract_address_const::<'new_descriptor'>()
        );

        assert(
            contract_state
                .descriptor_custom
                .read()
                .contract_address == contract_address_const::<'new_descriptor'>(),
            'wrong descriptor'
        );
    }

    #[test]
    #[should_panic(expected: ('Caller is not the owner',))]
    fn test_update_descriptor_custom__caller_not_owner() {
        let mut contract_state = call_constructor();

        // unknown address changes the descriptor
        start_prank(
            CheatTarget::One(starknet::get_contract_address()),
            contract_address_const::<'unknown_caller'>()
        );
        contract_state.owner_change_descriptor_custom(
            contract_address_const::<'new_descriptor'>()
        );
    }
}


#[cfg(test)]
mod blobert_read_endpoint_tests {
    use openzeppelin::token::erc721::erc721::ERC721Component::InternalTrait;
use blob::blobert::Blobert::__member_module_custom_image_counts::InternalContractMemberStateTrait as _F;
    use blob::blobert::Blobert::__member_module_descriptor_regular::InternalContractMemberStateTrait as _P;
    use blob::blobert::Blobert::__member_module_descriptor_custom::InternalContractMemberStateTrait as __P;
    use blob::blobert::Blobert::__member_module_mint_start_time::InternalContractMemberStateTrait as _K;
    use blob::blobert::Blobert::__member_module_regular_nft_seeder::InternalContractMemberStateTrait;
    use blob::blobert::Blobert::__member_module_regular_nft_seeds::InternalContractMemberStateTrait as _G;

    use blob::blobert::Blobert::__member_module_supply::InternalContractMemberStateTrait as _A;


    use blob::blobert::Blobert;
    use blob::blobert::IBlobert;
    use blob::descriptor::descriptor_regular::IDescriptorRegularDispatcher;
    use blob::descriptor::descriptor_custom::IDescriptorCustomDispatcher;
    use blob::seeder::ISeederDispatcher;
    use blob::seeder::ISeederDispatcherTrait;
    use blob::tests::unit_tests::utils::{
        ERC721_NAME, ERC721_SYMBOL, OWNER, MINTER, MINTER_RECIPIENT, SEEDER, DESCRIPTOR_REGULAR, DESCRIPTOR_CUSTOM,
        MERKLE_ROOTS, MINT_START_TIME, _50_ONE_OF_ONE_RECIPIENTS, FEE_TOKEN_ADDRESS, FEE_TOKEN_AMOUNT,
        deploy_fee_token, deploy_seeder,
        deploy_descriptor_regular, deploy_descriptor_custom, create_merkle_tree
    };
    use blob::types::erc721::Supply;
    use blob::types::erc721::TokenTrait;
    use blob::types::seeder::Seed;


    use core::array::ArrayTrait;
    use core::array::SpanTrait;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use openzeppelin::token::erc20::interface::IERC20DispatcherTrait;


    use openzeppelin::token::erc721::interface::IERC721;

    use snforge_std::{
        declare, ContractClassTrait, start_warp, start_prank, stop_prank, CheatTarget, start_spoof,
        TxInfoMock, TxInfoMockTrait
    };
    use starknet::ContractAddress;

    use starknet::contract_address_const;


    fn call_constructor() -> Blobert::ContractState {
        let mut contract_state = Blobert::contract_state_for_testing();
        Blobert::constructor(
            ref contract_state,
            ERC721_NAME(),
            ERC721_SYMBOL(),
            OWNER(),
            SEEDER(),
            DESCRIPTOR_REGULAR(),
            DESCRIPTOR_CUSTOM(),
            FEE_TOKEN_ADDRESS.try_into().unwrap(),
            FEE_TOKEN_AMOUNT.into(),
            MERKLE_ROOTS(),
            MINT_START_TIME(),
            _50_ONE_OF_ONE_RECIPIENTS().span()
        );

        return contract_state;
    }

    #[test]
    fn test_supply() {
        let mut contract_state = call_constructor();
        let supply = Supply { total_nft: 90, custom_nft: 50 };
        contract_state.supply.write(supply);
        assert(contract_state.supply() == supply, 'wrong supply');
    }


    #[test]
    fn test_max_supply() {
        let contract_state = call_constructor();
        assert(contract_state.max_supply() == 4844, 'wrong max supply');
    }

    #[test]
    fn test_seeder() {
        let mut contract_state = call_constructor();
        let seeder_dispatcher = ISeederDispatcher {
            contract_address: contract_address_const::<1337>()
        };
        contract_state.regular_nft_seeder.write(seeder_dispatcher);
        assert(contract_state.seeder() == seeder_dispatcher.contract_address, 'wrong seeder');
    }


    #[test]
    fn test_descriptor_regular() {
        let mut contract_state = call_constructor();
        let descriptor_dispatcher = IDescriptorRegularDispatcher {
            contract_address: contract_address_const::<1337>()
        };
        contract_state.descriptor_regular.write(descriptor_dispatcher);
        assert(
            contract_state.descriptor_regular() == descriptor_dispatcher.contract_address,
            'wrong descriptor'
        );
    }

    #[test]
    fn test_descriptor_custom() {
        let mut contract_state = call_constructor();
        let descriptor_dispatcher = IDescriptorCustomDispatcher {
            contract_address: contract_address_const::<1337>()
        };
        contract_state.descriptor_custom.write(descriptor_dispatcher);
        assert(
            contract_state.descriptor_custom() == descriptor_dispatcher.contract_address,
            'wrong descriptor'
        );
    }


    #[test]
    fn test_mint_time() {
        let mut contract_state = call_constructor();
        let mint_start_time = MINT_START_TIME();
        contract_state.mint_start_time.write(mint_start_time);
        assert(contract_state.mint_time() == mint_start_time, 'wrong mint time');
    }

    #[test]
    fn test_traits() {
        let mut contract_state = call_constructor();
        contract_state.erc721._mint(contract_address_const::<'someone'>(), 1337);
        contract_state.custom_image_counts.write(1337, 44);
        assert(
            contract_state.traits(1337) == TokenTrait::Custom(44 - 1),
            'wrong first identifier'
        );

        let seed = Seed { background: 1, armour: 1, jewelry: 1, mask: 1, weapon: 1 };
        contract_state.erc721._mint(contract_address_const::<'someone_else'>(), 1338);
        contract_state.regular_nft_seeds.write(1338, seed);
        assert(
            contract_state.traits(1338) == TokenTrait::Regular(seed),
            'wrong second identifier'
        );
    }
}
