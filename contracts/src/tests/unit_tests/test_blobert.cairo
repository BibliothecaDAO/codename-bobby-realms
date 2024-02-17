#[cfg(test)]
mod blobert_constructor_tests {

    use blob::blobert::Blobert::__member_module_dev_merkle_root::InternalContractMemberStateTrait as _T;
    use blob::blobert::Blobert::__member_module_realm_holder_merkle_root::InternalContractMemberStateTrait as __T;
    use blob::blobert::Blobert::__member_module_descriptor::InternalContractMemberStateTrait as ___T;
    use blob::blobert::Blobert::__member_module_seeder::InternalContractMemberStateTrait as ____T;
    use blob::blobert::Blobert::__member_module_mint_time::InternalContractMemberStateTrait as _____T;
    use openzeppelin::access::ownable::interface::IOwnable;
    use openzeppelin::token::erc721::interface::IERC721Metadata;

    use blob::blobert::Blobert;
    use blob::tests::unit_tests::utils::{
        ERC721_NAME, ERC721_SYMBOL, OWNER, SEEDER, DESCRIPTOR, 
        DEV_MERKLE_ROOT, REALM_HOLDER_MERKLE_ROOT, MINT_TIME,
    };

    use starknet::contract_address_const;

    

    #[test]
    fn test_constructor() {
        let mut contract_state = Blobert::contract_state_for_testing();
        Blobert::constructor(
            ref contract_state,
            ERC721_NAME(),
            ERC721_SYMBOL(),
            OWNER(),
            SEEDER(),
            DESCRIPTOR(),
            DEV_MERKLE_ROOT(),
            REALM_HOLDER_MERKLE_ROOT(),
            MINT_TIME()
        );

        // ensure erc721 name and symbol name are correct
        assert(contract_state.erc721.name() ==  ERC721_NAME(), 'wrong erc721 name');
        assert(contract_state.erc721.symbol() ==  ERC721_SYMBOL(), 'wrong erc721 name');

        // ensure owner address is accurate
        assert(contract_state.ownable.owner() ==  OWNER(), 'wrong owner address');

        // ensure seeder and descriptor are correct
        assert(contract_state.seeder.read().contract_address ==  SEEDER(), 'wrong seeder address');
        assert(contract_state.descriptor.read().contract_address ==  DESCRIPTOR(), 'wrong descriptor address');


        // ensure merkle roots are correct
        assert(contract_state.dev_merkle_root.read() ==  DEV_MERKLE_ROOT(), 'wrong dev merkle root');
        assert(contract_state.realm_holder_merkle_root.read() ==  REALM_HOLDER_MERKLE_ROOT(), 'wrong holder merkle root');

        // ensure mint time is accurate
        assert(contract_state.mint_time.read() == MINT_TIME(), 'wrong mint time');

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
            DESCRIPTOR(),
            DEV_MERKLE_ROOT(),
            REALM_HOLDER_MERKLE_ROOT(),
            MINT_TIME()
        );

    }

}


#[cfg(test)]
mod blobert_internal_tests {

    use core::array::SpanTrait;
    use blob::seeder::ISeederDispatcherTrait;
    use core::debug::PrintTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};
    use core::poseidon::{PoseidonTrait, poseidon_hash_span};

    use openzeppelin::token::erc721::interface::IERC721;
    use openzeppelin::token::erc20::interface::IERC20DispatcherTrait;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use blob::blobert::Blobert::InternalTrait;
    use blob::blobert::Blobert::__member_module_dev_merkle_root::InternalContractMemberStateTrait as _A;
    use blob::blobert::Blobert::__member_module_realm_holder_merkle_root::InternalContractMemberStateTrait as _B;
    use blob::blobert::Blobert::__member_module_descriptor::InternalContractMemberStateTrait as _C;
    use blob::blobert::Blobert::__member_module_seeder::InternalContractMemberStateTrait as _D;
    use blob::blobert::Blobert::__member_module_mint_time::InternalContractMemberStateTrait as _E;
    use blob::blobert::Blobert::__member_module_seeds::InternalContractMemberStateTrait as _F;
    use blob::blobert::Blobert::__member_module_seed_exists::InternalContractMemberStateTrait as _G;
    use blob::blobert::Blobert::__member_module_special_token_map::InternalContractMemberStateTrait as _H;
    use blob::blobert::Blobert::__member_module_special_token_count::InternalContractMemberStateTrait as _I;

    use snforge_std::{
        declare, ContractClassTrait, start_warp, start_prank, stop_prank, CheatTarget,
        start_spoof, TxInfoMock, TxInfoMockTrait
    };
    

    use blob::blobert::Blobert;
    use blob::tests::unit_tests::utils::{
        SEEDER, DESCRIPTOR, DEV_MERKLE_ROOT, REALM_HOLDER_MERKLE_ROOT, MINT_TIME,
        deploy_fee_token, deploy_seeder, deploy_descriptor,
        create_merkle_tree
    };

    use starknet::contract_address_const;


    ////////////////////////////////////////////////////
    //                  INITIALIZE 
    ////////////////////////////////////////////////////
    

    

    #[test]
    fn test_initialize() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.initialize(
            SEEDER(),
            DESCRIPTOR(),
            DEV_MERKLE_ROOT(),
            REALM_HOLDER_MERKLE_ROOT(),
            MINT_TIME()
        );

        // ensure seeder and descriptor are correct
        assert(contract_state.seeder.read().contract_address ==  SEEDER(), 'wrong seeder address');
        assert(contract_state.descriptor.read().contract_address ==  DESCRIPTOR(), 'wrong descriptor address');

        // ensure mint time is accurate
        assert(contract_state.mint_time.read() == MINT_TIME(), 'wrong mint time');

        // ensure merkle roots are correct
        assert(contract_state.dev_merkle_root.read() ==  DEV_MERKLE_ROOT(), 'wrong dev merkle root');
        assert(contract_state.realm_holder_merkle_root.read() ==  REALM_HOLDER_MERKLE_ROOT(), 'wrong holder merkle root');
    }



    #[test]
    #[should_panic(expected: ('Blobert: time whtlst not future',))]
    fn test_initialize_whitelist_mint_time_not_in_future() {
        let mut contract_state = Blobert::contract_state_for_testing();

        // set current time to equal mint time
        let mint_time = MINT_TIME();
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), 
            mint_time.whitelist
        );

        contract_state.initialize(
            SEEDER(),
            DESCRIPTOR(),
            DEV_MERKLE_ROOT(),
            REALM_HOLDER_MERKLE_ROOT(),
            mint_time
        );

    }



    #[test]
    #[should_panic(expected: ('Blobert: time reg less whitelst',))]
    fn test_initialize_regular_mint_time_not_greater_than_whitelist() {
        let mut contract_state = Blobert::contract_state_for_testing();

        // set regualar mint time == whitelist mint time
        let mut mint_time = MINT_TIME();
        mint_time.regular = mint_time.whitelist;

        contract_state.initialize(
            SEEDER(),
            DESCRIPTOR(),
            DEV_MERKLE_ROOT(),
            REALM_HOLDER_MERKLE_ROOT(),
            mint_time
        );
    }


    #[test]
    #[should_panic(expected: ('Blobert: no merkle root',))]
    fn test_initialize_no_dev_merkle_root() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.initialize(
            SEEDER(),
            DESCRIPTOR(),
            Zeroable::zero(),
            REALM_HOLDER_MERKLE_ROOT(),
            MINT_TIME()
        );
    }



    #[test]
    #[should_panic(expected: ('Blobert: no merkle root',))]
    fn test_initialize_no_realm_holder_merkle_root() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.initialize(
            SEEDER(),
            DESCRIPTOR(),
            DEV_MERKLE_ROOT(),
            Zeroable::zero(),
            MINT_TIME()
        );
    }



    ////////////////////////////////////////////////////
    //                  INTERNAL MINT
    ////////////////////////////////////////////////////

    #[test]
    fn test_internal_mint_collect_fee() {

        let minter = contract_address_const::<'minter'>();
        let minter_elected_recipient = contract_address_const::<'minter_elected_recipient'>();

        // deploy fee token 
        let fee_token 
            = deploy_fee_token(
                deploy_at: Blobert::FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                supply: Blobert::FEE_TOKEN_AMOUNT.into(),
                supply_recipient: minter
            );
        
        // ensure that the fee token address was successfully mocked
        assert(fee_token.contract_address == Blobert::FEE_TOKEN_ADDRESS.try_into().unwrap(),
                 'wrong fee token address');
        let minter_initial_balance = fee_token.balance_of(minter);

        // minter approves x $lords to be spent by blobert nft
        start_prank(CheatTarget::One(fee_token.contract_address), minter);
        fee_token.approve(snforge_std::test_address(), Blobert::FEE_TOKEN_AMOUNT.into());
        stop_prank(CheatTarget::One(fee_token.contract_address));

        // call blobert internal mint
        let mut contract_state = Blobert::contract_state_for_testing();
        let token_id = 1;
        contract_state.internal_mint(
            token_id, 
            caller: minter,
            recipient: minter_elected_recipient, 
            collect_fee: true
        );

        // ensure token was minted to correct recipient
        assert(
            contract_state.erc721.owner_of(token_id.into()) == minter_elected_recipient, 
                'wrong recipient nft balance'
        );
        
        // ensure minter has accurate balance
        assert(
            fee_token.balance_of(minter) 
                == minter_initial_balance - Blobert::FEE_TOKEN_AMOUNT.into(), 
                    'wrong minter erc20 balance'
        );

        // ensure fee recipient has accurate balance
        assert(
            fee_token.balance_of(Blobert::FEE_RECIPIENT_ADDRESS.try_into().unwrap()) 
                == Blobert::FEE_TOKEN_AMOUNT.into(), 
                'wrong minter balance'
        );


        // ensure minter's allowance was spent
        assert(
            fee_token.allowance(minter, snforge_std::test_address()) == 0,
            'wrong allowance balance'
        )
    }


    #[test]
    #[should_panic(expected: ('Blobert: insufficient fund',))]
    fn test_internal_mint_collect_fee_insuffifient_balance() {

        let minter = contract_address_const::<'minter'>();
        let minter_elected_recipient = contract_address_const::<'minter_elected_recipient'>();

        // deploy fee token 
        let _
            = deploy_fee_token(
                deploy_at: Blobert::FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                supply: 0, // mint nothing
                supply_recipient: minter
            );
        

        // call blobert internal mint
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.internal_mint(
            token_id: 1, 
            caller: minter,
            recipient: minter_elected_recipient, 
            collect_fee: true
        );
    }



    #[test]
    #[should_panic(expected: ('Blobert: insufficient approval',))]
    fn test_internal_mint_collect_fee_insuffifient_approval() {

        let minter = contract_address_const::<'minter'>();
        let minter_elected_recipient = contract_address_const::<'minter_elected_recipient'>();

        // deploy fee token 
        let _
            = deploy_fee_token(
                deploy_at: Blobert::FEE_TOKEN_ADDRESS.try_into().unwrap(), 
                supply: Blobert::FEE_TOKEN_AMOUNT.into(),
                supply_recipient: minter
            );
        
        // call blobert internal mint
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.internal_mint(
            token_id: 1, 
            caller: minter,
            recipient: minter_elected_recipient, 
            collect_fee: true
        );
    }


    #[test]
    fn test_internal_mint_no_collect_fee() {

        let minter = contract_address_const::<'minter'>();
        let minter_elected_recipient = contract_address_const::<'minter_elected_recipient'>();

        // call blobert internal mint
        let mut contract_state = Blobert::contract_state_for_testing();
        let token_id = 1;
        contract_state.internal_mint(
            token_id, 
            caller: minter,
            recipient: minter_elected_recipient, 
            collect_fee: false
        );

        // ensure token was minted to correct recipient
        assert(
            contract_state.erc721.owner_of(token_id.into()) == minter_elected_recipient, 
                'wrong recipient nft balance'
        );
    }



    ////////////////////////////////////////////////////
    //                  CALLER WON LOTTERY
    ////////////////////////////////////////////////////




    #[test]
    fn test_caller_won_special_token() {

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

            if contract_state.caller_won_special_token(){
                win_count += 1;
            };


            i += 1;
        };

        // ensure that the win rate is +2 or -2 from the expected win count

        let expected_win_count 
            = num_runs / Blobert::LOSE_SPECIAL_TOKEN_DRAW_WEIGHT.try_into().unwrap();
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
        let descriptor = deploy_descriptor();
        contract_state.seeder.write(seeder);
        contract_state.descriptor.write(descriptor);

        let token_id = 1;
         contract_state
                .set_regular_image(token_id);

        let seed = contract_state.seeds.read(token_id);
        assert!(seed.background != 0, "background not set");
        assert!(seed.armour != 0, "armour not set");
        assert!(seed.weapon != 0, "weapon not set");
        assert!(seed.mask != 0, "mask not set");
        assert!(seed.jewellry != 0, "jewellry not set");


        let seed_hash = poseidon::poseidon_hash_span(
            array![
                seed.background.into(), 
                seed.armour.into(), 
                seed.jewellry.into(), 
                seed.mask.into(), 
                seed.weapon.into()
            ].span()
        );        

        assert!(contract_state.seed_exists.read(seed_hash), "seed not added");  
    }


    #[test]
    fn test_set_regular_image_with_collision() {


        let mut contract_state = Blobert::contract_state_for_testing();
        
        // deploy and set seeder and descriptor contracts
        let seeder = deploy_seeder();
        let descriptor = deploy_descriptor();
        contract_state.seeder.write(seeder);
        contract_state.descriptor.write(descriptor);

        let token_id = 1;


        // make first seed exist
        let first_seed_salt = 0;
        let first_seed 
            = seeder.generate_seed(
                    token_id, descriptor.contract_address, first_seed_salt
                );
        let first_seed_hash: felt252 = PoseidonTrait::new().update_with(first_seed).finalize();        
         contract_state.seed_exists.write(first_seed_hash, true);

        // generate another seed for same token id
         contract_state
                .set_regular_image(token_id);
        
        let second_seed = contract_state.seeds.read(token_id);
        let second_seed_salt = first_seed_salt + 1;
        let expected_second_seed 
            = seeder.generate_seed(
                    token_id, descriptor.contract_address, second_seed_salt
                );

        assert!(second_seed == expected_second_seed, "wrong second seed");
    }




    ////////////////////////////////////////////////////
    //                 SET SPECIAL IMAGE
    ////////////////////////////////////////////////////





    #[test]
    fn test_set_special_image() {

        let mut contract_state = Blobert::contract_state_for_testing();
        

        // set special token for token id 1
         contract_state
                .set_special_image(1);

        assert!(
            contract_state.special_token_map.read(1) == 1, 
                "wrong token count map value (1)"
        );


        assert!(
            contract_state.special_token_count.read() == 1, 
                "wrong special token count (1)"
        );



        // set special token for token id 2 and 3
        contract_state.set_special_image(2);
        contract_state.set_special_image(3);

        assert!(
            contract_state.special_token_map.read(2) == 2, 
                "wrong token count map value (2)"
        );
        assert!(
            contract_state.special_token_map.read(3) == 3, 
                "wrong token count map value (3)"
        );


        assert!(
            contract_state.special_token_count.read() == 3, 
                "wrong special token count (3)"
        );

    }



    ////////////////////////////////////////////////////
    //          ENSURE WHITELIST MINT PERIOD
    ////////////////////////////////////////////////////





    #[test]
    fn test_ensure_whitelist_mint_period() {

        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_time = MINT_TIME();
        //      set mint time
        // everything should be okay since now 
        // >= whitelist time and now < mint_time.regular
        contract_state.mint_time.write(mint_time);

        // set block.timestamp to be after whitelist time
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), 
            mint_time.whitelist + 1
        );
        assert!(starknet::get_block_timestamp() > mint_time.whitelist , "timestamp not warpped");
        assert!(starknet::get_block_timestamp() < mint_time.regular , "regular should be set to higher than block ts");

        contract_state.ensure_whitelist_mint_period();

    }


    #[test]
    #[should_panic(expected: ('Blobert: whtelst mint not begun',))]
    fn test_ensure_whitelist_mint_period__before_mint_period() {

        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_time = MINT_TIME();
        contract_state.mint_time.write(mint_time);

        // set block.timestamp to be before whitelist time
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), 
            mint_time.whitelist - 1
        );


        contract_state.ensure_whitelist_mint_period();
    }


    #[test]
    #[should_panic(expected: ('Blobert: whitelist mint ended',))]
    fn test_ensure_whitelist_mint_period__after_mint_period() {

        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_time = MINT_TIME();
        contract_state.mint_time.write(mint_time);

        // set block.timestamp to be time for regular mint
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), 
            mint_time.regular
        );

        contract_state.ensure_whitelist_mint_period();
    }
        
    


    ////////////////////////////////////////////////////
    //          ENSURE REGULAR MINT PERIOD
    ////////////////////////////////////////////////////




    
    #[test]
    fn test_ensure_regular_mint_period() {

        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_time = MINT_TIME();
        contract_state.mint_time.write(mint_time);

        // set block.timestamp to be time regular mint
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), 
            mint_time.regular
        );


        // call ensure period
        contract_state.ensure_regular_mint_period();


        // set block.timestamp to be after regular mint time
        // since it has no end, this should work too
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), 
            mint_time.regular + 1
        );

        // call ensure period again
        contract_state.ensure_regular_mint_period();
    }


    #[test]
    #[should_panic(expected: ('Blobert: reg mint not started',))]
    fn test_ensure_regular_mint_period__before_mint_period() {

        let mut contract_state = Blobert::contract_state_for_testing();
        let mint_time = MINT_TIME();
        contract_state.mint_time.write(mint_time);

        // set block.timestamp to be before regular mint time
        start_warp(
            CheatTarget::One(starknet::get_contract_address()), 
            mint_time.regular - 1
        );

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

        let (merkle_proof, merkle_root) 
            = create_merkle_tree(starknet::get_contract_address());
    
        // ensure call does not fail
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.ensure_valid_merkle_proof(
            starknet::get_contract_address(),
            merkle_proof,
            merkle_root
        )
    }


    #[test]
    #[should_panic(expected: ('Blobert: not in merkletree',))]
    fn test_ensure_valid_merkle_tree__bad_proof() {

        let (mut merkle_proof, merkle_root) 
            = create_merkle_tree(starknet::get_contract_address());

        // corrupt proof
        let _ = merkle_proof.pop_back();

        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.ensure_valid_merkle_proof(
            starknet::get_contract_address(),
            merkle_proof,
            merkle_root
        )
    }


    #[test]
    #[should_panic(expected: ('Blobert: not in merkletree',))]
    fn test_ensure_valid_merkle_tree__bad_root() {

        let (merkle_proof, mut merkle_root) 
            = create_merkle_tree(starknet::get_contract_address());

        // corrupt root
        merkle_root += 1;

        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.ensure_valid_merkle_proof(
            starknet::get_contract_address(),
            merkle_proof,
            merkle_root
        )
    }



    ////////////////////////////////////////////////////
    //          SET SEEDER CONTRACT
    ////////////////////////////////////////////////////




    #[test]
    fn test_set_seeder() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.set_seeder(
            contract_address_const::<'seeder'>()
        )
    }

    #[test]
    #[should_panic(expected: ('Blobert: zero addr seeder',))]
    fn test_set_seeder_zero() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.set_seeder(
            Zeroable::zero()
        )
    }



    ////////////////////////////////////////////////////
    //          SET DESCRIPTOR CONTRACT
    ////////////////////////////////////////////////////



    #[test]
    fn test_set_descriptor() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.set_descriptor(
            contract_address_const::<'descriptor'>()
        )
    }

    #[test]
    #[should_panic(expected: ('Blobert: zero addr descriptor',))]
    fn test_set_descriptor_zero() {
        let mut contract_state = Blobert::contract_state_for_testing();
        contract_state.set_descriptor(
            Zeroable::zero()
        )
    }
    
}







#[cfg(test)]
mod blobert_endpoint_tests {

    use core::array::SpanTrait;
    use blob::seeder::ISeederDispatcherTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};

    use openzeppelin::token::erc721::interface::IERC721;
    use openzeppelin::token::erc20::interface::IERC20DispatcherTrait;

    use snforge_std::{
        declare, ContractClassTrait, start_warp, start_prank, stop_prank, CheatTarget,
        start_spoof, TxInfoMock, TxInfoMockTrait
    };
    

    use blob::blobert::Blobert;
    use blob::tests::unit_tests::utils::{
        SEEDER, DESCRIPTOR, DEV_MERKLE_ROOT, REALM_HOLDER_MERKLE_ROOT, MINT_TIME,
        deploy_fee_token, deploy_seeder, deploy_descriptor, deploy_blobert,
        create_merkle_tree
    };


}
