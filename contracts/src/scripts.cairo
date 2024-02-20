#[cfg(test)]
mod merkle_tree {
    use core::clone::Clone;
use alexandria_merkle_tree::merkle_tree::{
        Hasher, MerkleTree, poseidon::PoseidonHasherImpl, MerkleTreeTrait, HasherTrait, MerkleTreeImpl
    };
    use core::hash::{HashStateTrait, HashStateExTrait};
    use core::poseidon::PoseidonTrait;
    use core::traits::TryInto;
    use debug::PrintTrait;



    #[test]
    #[ignore]
    fn generate_merkle_roots() {

        let (_, merkle_root) = get_merkle(tier_1(), 0);
        println!("\n\n        Tier 1 Merkle Root : \n");
        merkle_root.print();
        println!("\n\n\n");


        let (_, merkle_root) = get_merkle(tier_2(), 0);
        println!("\n\n        Tier 2 Merkle Root : \n");
        merkle_root.print();
        println!("\n\n\n");


        let (_, merkle_root) = get_merkle(tier_3(), 0);
        println!("\n\n        Tier 3 Merkle Root : \n");
        merkle_root.print();
        println!("\n\n\n");

        let (_, merkle_root) = get_merkle(tier_4(), 0);
        println!("\n\n        Tier 4 Merkle Root : \n");
        merkle_root.print();
        println!("\n\n\n");

        let (_, merkle_root) = get_merkle(tier_5(), 0);
        println!("\n\n        Tier 5 Merkle Root : \n");
        merkle_root.print();
        println!("\n\n\n");
    }


    #[test]
    #[ignore]
    fn show_proof() {

        let leaf_index = 0;
        let tier = tier_1();
      
        let (merkle_proof, merkle_root) = get_merkle(tier.clone(), leaf_index);
        println!("\n\n  Merkle Root : \n");
        merkle_root.print();
        println!("\n\n");


        println!("\n\n  Merkle Proof : \n");
        let mut merkle_proof_clone = merkle_proof.clone();
        loop {
            match merkle_proof_clone.pop_front() {
                Option::Some(proof) => {
                    println!("\n");

                    (*proof).print();
                }, 
                Option::None => {break;}
            }
        };

        println!("\n\n\n");

        let leaf = *apply_poseidon_per_element(tier)[leaf_index];
        verify(merkle_proof, merkle_root, leaf);

    }



    fn get_merkle(mut whitelist_addresses: Array<felt252>, leaf_index: u32) -> (Span<felt252>, felt252) {
        let leaves 
            = apply_poseidon_per_element(whitelist_addresses);

        // [Setup] Merkle tree.
        let mut merkle_tree: MerkleTree<Hasher> = MerkleTreeImpl::<_, PoseidonHasherImpl>::new();
        let leaf: felt252 = *leaves.at(leaf_index);


        // compute merkle proof.
        let merkle_proof = MerkleTreeImpl::<
            _, PoseidonHasherImpl
        >::compute_proof(ref merkle_tree, leaves, leaf_index);

        // compute merkle root.
        let merkle_root = MerkleTreeImpl::<
            _, PoseidonHasherImpl
        >::compute_root(ref merkle_tree, leaf, merkle_proof);

        (merkle_proof, merkle_root)
    }



    fn verify(merkle_proof: Span<felt252>, merkle_root: felt252, leaf: felt252, ) {

        let mut merkle_tree: MerkleTree<Hasher> = MerkleTreeImpl::<_, PoseidonHasherImpl>::new();

        // verify a valid proof.
        let verified = MerkleTreeImpl::<
            _, PoseidonHasherImpl
        >::verify(ref merkle_tree, merkle_root, leaf, merkle_proof);

        if verified {
            println!("\n\n Proof is valid \n\n");
        } else {
            println!("\n\n Proof is NOT valid \n\n");
        }
    }




    fn tier_1()-> Array<felt252> {
        return array![
            0x06a4d4e8c1cc9785e125195a2f8bd4e5b0c7510b19f3e2dd63533524f5687e41,
            0x44, 
            0x978189,
            0x9129139,
            0x81288318130,
            0x8129901309093109ACCAAAAAAAAAAAAAAA,
            0x8778128388129012902999AEAEAAAAFFFFFFFA,
            0x13377777777777777777778128388129012902999AEAEAAAAFFFFFFFA
        ];

    }

    fn tier_2()-> Array<felt252> {
        return array![
            0x05238b194B2d5FCC189955C1E84d794afefdC6114A9eAf550FB0F5CE8701D70E,
            0x44, 
            0x978189,
            0x9129139,
            0x81288318130,
            0x8129901309093109ACCAAAAAAAAAAAAAAA,
            0x8778128388129012902999AEAEAAAAFFFFFFFA,
            0x14477777777777777777778128388129012902999AEAEAAAAFFFFFFFA
        ];

    }


    fn tier_3()-> Array<felt252> {
        return array![
            0x06a4d4e8c1cc9785e125195a2f8bd4e5b0c7510b19f3e2dd63533524f5687e41,
            0x05238b194B2d5FCC189955C1E84d794afefdC6114A9eAf550FB0F5CE8701D70E,
            0x44, 
            0x978189,
            0x9129139,
            0x81288318130,
            0x8129901309093109ACCAAAAAAAAAAAAAAA,
            0x8778128388129012902999AEAEAAAAFFFFFFFA,
            0x15577777777777777777778128388129012902999AEAEAAAAFFFFFFFA
        ];

    }

    fn tier_4()-> Array<felt252> {
        return array![
            0x06a4d4e8c1cc9785e125195a2f8bd4e5b0c7510b19f3e2dd63533524f5687e41,
            0x05238b194B2d5FCC189955C1E84d794afefdC6114A9eAf550FB0F5CE8701D70E,
            0x44, 
            0x978189,
            0x9129139,
            0x81288318130,
            0x8129901309093109ACCAAAAAAAAAAAAAAA,
            0x8778128388129012902999AEAEAAAAFFFFFFFA,
            0x1667777777777777777778128388129012902999AEAEAAAAFFFFFFFA
        ];
    }


    fn tier_5()-> Array<felt252> {
        return array![
            0x06a4d4e8c1cc9785e125195a2f8bd4e5b0c7510b19f3e2dd63533524f5687e41,
            0x05238b194B2d5FCC189955C1E84d794afefdC6114A9eAf550FB0F5CE8701D70E,
            0x44, 
            0x978189,
            0x9129139,
            0x81288318130,
            0x8129901309093109ACCAAAAAAAAAAAAAAA,
            0x8778128388129012902999AEAEAAAAFFFFFFFA,
            0x17777777777777777777778128388129012902999AEAEAAAAFFFFFFFA
        ];

    }


    fn apply_poseidon_per_element(mut values: Array<felt252>) -> Array<felt252> {
        let mut hashed_addresses = array![];
        loop {
            match values.pop_front() {
                Option::Some(address) => {
                    let hash =
                            PoseidonTrait::new().update_with(address).finalize();
                    hashed_addresses.append(hash);
                },
                Option::None => {break;}
            }
        };
        hashed_addresses
    }


}