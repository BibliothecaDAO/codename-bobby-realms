use core::serde::Serde;
use blob::types::erc721::MintTime;
use core::integer::BoundedInt;
use starknet::ContractAddress;



// Constants 

fn ERC721_NAME() -> felt252 {
    'Blobert'
}

fn ERC721_SYMBOL() -> felt252 {
    'BLOB'
}

fn OWNER() -> ContractAddress {
    'OWNER'.try_into().unwrap()
}

fn SEEDER() -> ContractAddress {
    'SEEDER'.try_into().unwrap()
}

fn DESCRIPTOR() -> ContractAddress {
    'DESCRIPTOR'.try_into().unwrap()
}


fn DEV_MERKLE_ROOT() -> felt252 {
    'DEV_MERKLE_ROOT'
}

fn REALM_HOLDER_MERKLE_ROOT() -> felt252 {
    'REALM_HOLDER_MERKLE_ROOT'
}

fn MINT_TIME() -> MintTime {
    MintTime {
        regular: BoundedInt::<u64>::max() - 100,
        whitelist: BoundedInt::<u64>::max() - 1_000
    }
}



use snforge_std::{declare, ContractClassTrait};
use openzeppelin::token::erc20::interface::IERC20Dispatcher;
use blob::seeder::ISeederDispatcher;
use blob::blobert::IBlobertDispatcher;
use blob::descriptor::IDescriptorDispatcher;


fn deploy_blobert() -> IBlobertDispatcher {
    let contract = declare('Blobert');
    let mut calldata: Array<felt252> = array![];

    ERC721_NAME().serialize(ref calldata);
    ERC721_SYMBOL().serialize(ref calldata);
    OWNER().serialize(ref calldata);
    SEEDER().serialize(ref calldata);
    DESCRIPTOR().serialize(ref calldata);
    DEV_MERKLE_ROOT().serialize(ref calldata);
    REALM_HOLDER_MERKLE_ROOT().serialize(ref calldata);
    MINT_TIME().serialize(ref calldata);

    let contract_address = contract.deploy(@calldata).unwrap();
    IBlobertDispatcher { contract_address }
}


            
fn deploy_fee_token(deploy_at: ContractAddress, supply: u256, supply_recipient: ContractAddress ) -> IERC20Dispatcher {
    let contract = declare('ERC20');
    let mut calldata: Array<felt252> = array![];

    let name: felt252 = 'Lords';
    let symbol: felt252 = '$lords';
    let fixed_supply: u256 = supply;

    name.serialize(ref calldata);
    symbol.serialize(ref calldata);
    fixed_supply.serialize(ref calldata);
    supply_recipient.serialize(ref calldata);

    let contract_address = contract.deploy_at(@calldata, deploy_at).unwrap();
    IERC20Dispatcher { contract_address }
}



fn deploy_seeder() -> ISeederDispatcher {
    let contract = declare('Seeder');
    let mut calldata: Array<felt252> = array![];

    let contract_address = contract.deploy(@calldata).unwrap();
    ISeederDispatcher { contract_address }
}


fn deploy_descriptor() -> IDescriptorDispatcher {
    let contract = declare('Descriptor');
    let mut calldata: Array<felt252> = array![];

    let contract_address = contract.deploy(@calldata).unwrap();
    IDescriptorDispatcher { contract_address }
}



use alexandria_merkle_tree::merkle_tree::{
    Hasher, MerkleTree, poseidon::PoseidonHasherImpl, MerkleTreeTrait, HasherTrait,
    MerkleTreeImpl
};


fn create_merkle_tree(leaf: ContractAddress) -> (Span<felt252>, felt252) {

    // [Setup] Merkle tree.
    let mut merkle_tree: MerkleTree<Hasher> = MerkleTreeImpl::<_, PoseidonHasherImpl>::new();
    let leaf: felt252 = leaf.into();
    let leaves = array![leaf, 0x2, 0x3, 0x9, 0x172, 0x132, 0x12333, 0x44];
    let leaf_index = 0;


    // compute merkle proof.
    let merkle_proof = MerkleTreeImpl::<
        _, PoseidonHasherImpl
    >::compute_proof(ref merkle_tree, leaves, leaf_index);
    

    // compute merkle root.
    let merkle_root = MerkleTreeImpl::<
        _, PoseidonHasherImpl
    >::compute_root(ref merkle_tree, leaf, merkle_proof);


    // verify a valid proof.
    let verified = MerkleTreeImpl::<
        _, PoseidonHasherImpl
    >::verify(ref merkle_tree, merkle_root, leaf, merkle_proof);
    assert(verified, 'verify valid proof failed');

    (merkle_proof, merkle_root)

}
