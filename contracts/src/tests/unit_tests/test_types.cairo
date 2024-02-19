#[cfg(test)]
mod types_tests {
    use blob::blobert::Blobert::__member_module_mint_start_time::InternalContractMemberStateTrait as _A;
    use blob::blobert::Blobert::__member_module_regular_nft_seeds::InternalContractMemberStateTrait as _P;
    use blob::blobert::Blobert::__member_module_supply::InternalContractMemberStateTrait;
    use blob::blobert::Blobert;
    use blob::types::erc721::MintStartTime;
    use blob::types::erc721::Supply;
    use blob::types::seeder::Seed;
    use core::integer::BoundedInt;
    use core::traits::TryInto;


    use starknet::contract_address_const;


    #[test]
    fn test_seed_store_packing_max_values() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let seed = Seed {
            background: BoundedInt::max(),
            armour: BoundedInt::max(),
            jewelry: BoundedInt::max(),
            mask: BoundedInt::max(),
            weapon: BoundedInt::max(),
        };

        contract_state.regular_nft_seeds.write(1, seed);
        let stored_seed = contract_state.regular_nft_seeds.read(1);
        assert(seed == stored_seed, 'wrong seed value');
    }

    #[test]
    fn test_seed_store_packing_max_random_values_1() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let seed = Seed {
            background: 0,
            armour: BoundedInt::max() - 18,
            jewelry: BoundedInt::max() - 44,
            mask: BoundedInt::max() - 100,
            weapon: BoundedInt::max() - 14,
        };

        contract_state.regular_nft_seeds.write(1, seed);
        let stored_seed = contract_state.regular_nft_seeds.read(1);
        assert(seed == stored_seed, 'wrong seed value');
    }


    #[test]
    fn test_seed_store_packing_max_random_values_2() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let seed = Seed {
            background: BoundedInt::max() - 19,
            armour: 0,
            jewelry: BoundedInt::max() - 154,
            mask: BoundedInt::max() - 10,
            weapon: BoundedInt::max() - 214,
        };

        contract_state.regular_nft_seeds.write(1, seed);
        let stored_seed = contract_state.regular_nft_seeds.read(1);
        assert(seed == stored_seed, 'wrong seed value');
    }


    #[test]
    fn test_seed_store_packing_max_random_values_3() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let seed = Seed {
            background: BoundedInt::max() - 0,
            armour: BoundedInt::max() - 10,
            jewelry: 0,
            mask: BoundedInt::max() - 0,
            weapon: 0,
        };

        contract_state.regular_nft_seeds.write(1, seed);
        let stored_seed = contract_state.regular_nft_seeds.read(1);
        assert(seed == stored_seed, 'wrong seed value');
    }


    #[test]
    fn test_mint_start_time_store_packing_max_values() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let mint_start_time = MintStartTime {
            regular: BoundedInt::max(), whitelist: BoundedInt::max(),
        };

        contract_state.mint_start_time.write(mint_start_time);
        let stored_mint_start_time = contract_state.mint_start_time.read();
        assert(mint_start_time == stored_mint_start_time, 'wrong start time value');
    }


    #[test]
    fn test_mint_start_time_store_packing_random_values_1() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let mint_start_time = MintStartTime {
            regular: 0, whitelist: BoundedInt::max() - 781222222221,
        };

        contract_state.mint_start_time.write(mint_start_time);
        let stored_mint_start_time = contract_state.mint_start_time.read();
        assert(mint_start_time == stored_mint_start_time, 'wrong start time value');
    }


    #[test]
    fn test_mint_start_time_store_packing_random_values_2() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let mint_start_time = MintStartTime {
            regular: BoundedInt::max() - 98129017, whitelist: 0,
        };

        contract_state.mint_start_time.write(mint_start_time);
        let stored_mint_start_time = contract_state.mint_start_time.read();
        assert(mint_start_time == stored_mint_start_time, 'wrong start time value');
    }


    #[test]
    fn test_mint_start_time_store_packing_random_values_3() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let mint_start_time = MintStartTime {
            regular: BoundedInt::max() - 49898182129017, whitelist: BoundedInt::max() - 90912222221,
        };

        contract_state.mint_start_time.write(mint_start_time);
        let stored_mint_start_time = contract_state.mint_start_time.read();
        assert(mint_start_time == stored_mint_start_time, 'wrong start time value');
    }


    #[test]
    fn test_supply_store_packing_max_values() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let supply = Supply { total_nft: BoundedInt::max(), custom_nft: BoundedInt::max() };

        contract_state.supply.write(supply);
        let stored_supply = contract_state.supply.read();
        assert(supply == stored_supply, 'wrong supply value');
    }


    #[test]
    fn test_supply_store_packing_random_values_1() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let supply = Supply { total_nft: BoundedInt::max(), custom_nft: 0 };

        contract_state.supply.write(supply);
        let stored_supply = contract_state.supply.read();
        assert(supply == stored_supply, 'wrong supply value');
    }

    #[test]
    fn test_supply_store_packing_random_values_2() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let supply = Supply { total_nft: 0, custom_nft: BoundedInt::max() };

        contract_state.supply.write(supply);
        let stored_supply = contract_state.supply.read();
        assert(supply == stored_supply, 'wrong supply value');
    }

    #[test]
    fn test_supply_store_packing_random_values_3() {
        let mut contract_state = Blobert::contract_state_for_testing();

        let supply = Supply { total_nft: BoundedInt::max() - 7889, custom_nft: BoundedInt::max() };

        contract_state.supply.write(supply);
        let stored_supply = contract_state.supply.read();
        assert(supply == stored_supply, 'wrong supply value');
    }
}
