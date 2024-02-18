use alexandria_merkle_tree::merkle_tree::{
    Hasher, MerkleTree, poseidon::PoseidonHasherImpl, MerkleTreeTrait, HasherTrait, MerkleTreeImpl
};
use blob::blobert::IBlobertDispatcher;
use blob::descriptor::descriptor_regular::IDescriptorRegularDispatcher;
use blob::descriptor::descriptor_custom::IDescriptorCustomDispatcher;
use blob::seeder::ISeederDispatcher;
use blob::types::erc721::MintStartTime;
use core::integer::BoundedInt;
use core::serde::Serde;
use core::traits::TryInto;
use openzeppelin::token::erc20::interface::IERC20Dispatcher;
use snforge_std::{declare, ContractClassTrait};
use starknet::ContractAddress;


fn deploy_blobert() -> IBlobertDispatcher {
    let contract = declare('Blobert');
    let mut calldata: Array<felt252> = array![];

    ERC721_NAME().serialize(ref calldata);
    ERC721_SYMBOL().serialize(ref calldata);
    OWNER().serialize(ref calldata);
    SEEDER().serialize(ref calldata);
    DESCRIPTOR_REGULAR().serialize(ref calldata);
    DESCRIPTOR_CUSTOM().serialize(ref calldata);
    MERKLE_ROOTS().serialize(ref calldata);
    MINT_START_TIME().serialize(ref calldata);

    let contract_address = contract.deploy(@calldata).unwrap();
    IBlobertDispatcher { contract_address }
}


fn deploy_fee_token(
    deploy_at: ContractAddress, supply: u256, supply_recipient: ContractAddress
) -> IERC20Dispatcher {
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

    let contract_address = contract.deploy_at(@calldata, 'SEEDER'.try_into().unwrap()).unwrap();
    ISeederDispatcher { contract_address }
}


fn deploy_descriptor_regular() -> IDescriptorRegularDispatcher {
    let contract = declare('DescriptorRegular');
    let mut calldata: Array<felt252> = array![];

    let contract_address = contract.deploy_at(@calldata, 'DESCRIPTOR'.try_into().unwrap()).unwrap();
    IDescriptorRegularDispatcher { contract_address }
}


fn deploy_descriptor_custom() -> IDescriptorCustomDispatcher {
    let contract = declare('DescriptorCustom');
    let mut calldata: Array<felt252> = array![];

    let contract_address = contract.deploy_at(@calldata, 'DESCRIPTOR'.try_into().unwrap()).unwrap();
    IDescriptorCustomDispatcher { contract_address }
}


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

fn MINTER() -> ContractAddress {
    'MINTER'.try_into().unwrap()
}

fn MINTER_RECIPIENT() -> ContractAddress {
    'MINTER_RECIPIENT'.try_into().unwrap()
}


fn SEEDER() -> ContractAddress {
    deploy_seeder().contract_address
}


fn DESCRIPTOR_REGULAR() -> ContractAddress {
    deploy_descriptor_regular().contract_address
}

fn DESCRIPTOR_CUSTOM() -> ContractAddress {
    deploy_descriptor_custom().contract_address
}


fn MERKLE_ROOTS() -> Span<felt252> {
    array![
        'merkle_root_tier_1_whitelist',
        'merkle_root_tier_2_whitelist',
        'merkle_root_tier_3_whitelist',
        'merkle_root_tier_4_whitelist',
        'merkle_root_tier_5_whitelist',
    ]
        .span()
}

fn MINT_START_TIME() -> MintStartTime {
    MintStartTime {
        regular: 104848548726390
            - 4, // 104848548726390 timestamp  with tx hash of 1234 gives you a custom token in test environment
        whitelist: 104848548726390 - 1_000_000
    }
}


fn _50_ONE_OF_ONE_RECIPIENTS() -> Array<ContractAddress> {
    // 50 unique recipients
    array![
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec540.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec541.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec542.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec543.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec544.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec545.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec547.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec548.try_into().unwrap(),
        0x059f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec549.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae0eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae2eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae3eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae4eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae5eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae6eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae7eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae8eec546.try_into().unwrap(),
        0x049f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae9eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d14fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d24fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d34fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d44fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d54fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d64fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d74fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d84fae1eec546.try_into().unwrap(),
        0x039f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d94fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c02b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c12b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c22b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c32b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c42b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c52b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c62b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c82b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x029f9205f50528a4c6308c69c675c14e65f31c92b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a0c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a1c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a2c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a3c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a4c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a5c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a6c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a7c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a8c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap(),
        0x019f9205f50528a9c6308c69c675c14e65f31c72b1f7f1d2375d04fae1eec546.try_into().unwrap()
    ]
}
