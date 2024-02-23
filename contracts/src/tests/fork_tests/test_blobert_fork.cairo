#[cfg(test)]
mod blobert_fork_tests {
    use blob::blobert::Blobert;
    use blob::blobert::{IBlobertDispatcher, IBlobertDispatcherTrait};
    use blob::seeder::ISeederDispatcherTrait;
    use blob::tests::contracts::erc20::{IERC20MintableDispatcher, IERC20MintableDispatcherTrait};
    use blob::tests::unit_tests::utils::{
        SEEDER, DESCRIPTOR_REGULAR, DESCRIPTOR_CUSTOM, MERKLE_ROOTS, MINT_START_TIME, MINTER,
        MINTER_RECIPIENT, _43_ONE_OF_ONE_RECIPIENTS, FEE_TOKEN_ADDRESS, FEE_TOKEN_AMOUNT,
        deploy_fee_token, deploy_seeder, deploy_descriptor_regular, deploy_descriptor_custom,
        create_merkle_tree
    };
    use blob::types::blobert::WhitelistTier;

    use core::array::SpanTrait;
    use core::debug::PrintTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};
    use core::option::OptionTrait;
    use core::poseidon::{PoseidonTrait, poseidon_hash_span};
    use core::traits::TryInto;
    use openzeppelin::token::erc20::interface::IERC20Dispatcher;
    use openzeppelin::token::erc20::interface::IERC20DispatcherTrait;

    use openzeppelin::token::erc721::interface::IERC721;
    use openzeppelin::token::erc721::interface::IERC721Dispatcher;
    use openzeppelin::token::erc721::interface::IERC721DispatcherTrait;
    use openzeppelin::token::erc721::interface::IERC721MetadataDispatcher;
    use openzeppelin::token::erc721::interface::IERC721MetadataDispatcherTrait;

    use snforge_std::{
        declare, ContractClassTrait, start_warp, start_prank, stop_prank, CheatTarget, start_spoof,
        TxInfoMock, TxInfoMockTrait, stop_spoof
    };

    use starknet::contract_address_const;


    #[test]
    // #[fork("SEPOLIA")]
    #[ignore]
    fn test_mint_fork() {
        let this = starknet::get_contract_address();
        let fee_token_address = 0x4ef0e2993abf44178d3a40f2818828ed1c09cde9009677b7a3323570b4c0f2e
            .try_into()
            .unwrap();

        let blobert_address: starknet::ContractAddress =
            0x3cea7b20d6fd38a1c9fc6166ff1f45543d9049b669187417f2552641a70d408
            .try_into()
            .unwrap();
        let mut blobert = IBlobertDispatcher { contract_address: blobert_address };

        let mut i = 180;
        loop {
            if i == 4844 {
                break;
            };

            let caller_felt = 0x7976771278805467 + i;
            let caller: starknet::ContractAddress = caller_felt.try_into().unwrap();
            start_prank(CheatTarget::One(fee_token_address), caller);
            IERC20MintableDispatcher { contract_address: fee_token_address }
                .mint(
                    300_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000
                );
            IERC20Dispatcher { contract_address: fee_token_address }
                .approve(
                    blobert_address,
                    300_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000
                );
            stop_prank(CheatTarget::One(fee_token_address));

            // mock transaction hash so it isnt 0
            let mut tx_info = TxInfoMockTrait::default();
            let tx = (i);
            let tx_hash = PoseidonTrait::new().update_with(tx).finalize();
            tx_info.transaction_hash = Option::Some(tx_hash);
            start_spoof(CheatTarget::One(blobert_address), tx_info);
            start_prank(CheatTarget::One(blobert_address), caller);

            let im = blobert.mint(this);
            println!("{}", im);

            i += 1;
        };
    }

    #[test]
    // #[fork("SEPOLIA")
    #[ignore]
    fn test_token_id_fork() {
        let blobert_address: starknet::ContractAddress =
            0x3cea7b20d6fd38a1c9fc6166ff1f45543d9049b669187417f2552641a70d408
            .try_into()
            .unwrap();
        let mut blobert = IERC721MetadataDispatcher { contract_address: blobert_address };
        let im = blobert.token_uri(51);
        println!("{}", im);
    }
}
