#[cfg(test)]
mod seeder_tests {
    use blob::seeder::ISeeder;
    use blob::seeder::Seed;
    use blob::seeder::Seeder;

    use blob::tests::unit_tests::utils::{SEEDER, DESCRIPTOR_REGULAR};
    use core::debug::PrintTrait;
    use core::dict::Felt252DictTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};
    use core::poseidon::PoseidonTrait;
    use core::traits::TryInto;
    use snforge_std::{start_warp, CheatTarget};

    use starknet::contract_address_const;


    #[test]
    fn test_generate_seed_different_token_ids() {
        // ensure seed is different for different token ids
        let mut contract_state = Seeder::contract_state_for_testing();

        let mut token_id = 440;
        let max_tokens = token_id + 90;
        let descriptor_regular_addr = DESCRIPTOR_REGULAR();

        let mut hash_map: Felt252Dict<bool> = Default::default();

        loop {
            if token_id == max_tokens {
                break;
            }

            let seed = contract_state.generate_seed(token_id, descriptor_regular_addr, 0);
            let seed_hash: felt252 = PoseidonTrait::new().update_with(seed).finalize();

            // let exists = hash_map.get(seed_hash); 
            // println!("hash: {}, token_id: {}, exists: {}", seed_hash, token_id,exists);

            assert(hash_map.get(seed_hash) == false, 'seed exists');

            hash_map.insert(seed_hash, true);

            token_id += 1
        }
    }


    #[test]
    fn test_generate_seed_different_salt() {
        // ensure seed is different for different salts
        let mut contract_state = Seeder::contract_state_for_testing();

        let token_id = 19;
        let mut salt = 0;
        let max_salts = 90;
        let descriptor_regular_addr = DESCRIPTOR_REGULAR();

        let mut hash_map: Felt252Dict<bool> = Default::default();

        loop {
            if salt == max_salts {
                break;
            }

            let seed = contract_state.generate_seed(token_id, descriptor_regular_addr, salt);
            let seed_hash: felt252 = PoseidonTrait::new().update_with(seed).finalize();

            // let exists = hash_map.get(seed_hash); 
            // println!("hash: {}, token_id: {}, salt: {}, exists: {}", seed_hash, token_id, salt, exists);

            assert(hash_map.get(seed_hash) == false, 'seed exists');

            hash_map.insert(seed_hash, true);

            salt += 1
        }
    }


    #[test]
    fn test_generate_seed_different_timestamp() {
        // ensure seed is different for different timestamps
        let mut contract_state = Seeder::contract_state_for_testing();

        let token_id = 8;
        let mut ts = 170835727;
        let max_ts = ts + 90;
        let descriptor_regular_addr = DESCRIPTOR_REGULAR();

        let mut hash_map: Felt252Dict<bool> = Default::default();

        loop {
            if ts == max_ts {
                break;
            }

            start_warp(CheatTarget::One(starknet::get_contract_address()), ts);

            let seed = contract_state.generate_seed(token_id, descriptor_regular_addr, 0);
            let seed_hash: felt252 = PoseidonTrait::new().update_with(seed).finalize();

            // let exists = hash_map.get(seed_hash); 
            // println!("hash: {}, token_id: {}, ts: {}, exists: {}", seed_hash, token_id, ts, exists);

            assert(hash_map.get(seed_hash) == false, 'seed exists');

            hash_map.insert(seed_hash, true);

            ts += 1
        }
    }


    #[test]
    fn test_generate_seed_sheep_wool_and_kirugimi() {
        // mask is between (0 and 7) when seed is sheep wool  or kigurumi (0 or 1)
        let mut contract_state = Seeder::contract_state_for_testing();

        let mut token_id = 0;
        let mut count = 0;
        let descriptor_regular_addr = DESCRIPTOR_REGULAR();

        loop {
            if count == 5 {
                break;
            }

            let seed = contract_state.generate_seed(token_id, descriptor_regular_addr, 0);
            if seed.armour == 0 || seed.armour == 1 {
                assert(seed.mask < 8, 'wrong seed value');
                count += 1
            }
            token_id += 1;
        }
    }
}
