use blob::generation::traits::armour;

const ARMOUR_COUNT: u32 = 9;
fn armours(index: u32) -> (ByteArray, ByteArray) {

    assert(index < ARMOUR_COUNT, 'wrong armour index');

    let index: felt252 = index.into();

    match index {
        0 => (armour::chainmail(), "Chainmail"),
        1 => (armour::demonarmour(), "Demon Armour"),
        2 => (armour::divinerobe(), "Divine Robe"),
        3 => (armour::kigurumi(), "Kigurumi"),
        4 => (armour::leatherarmour(), "Leather Armour"),
        5 => (armour::platemail(), "Plate Mail"),
        6 => (armour::robe(), "Robe"),
        7 => (armour::sheepswool(), "Sheep's Wool"),
        8 => (armour::underpants(), "Underpants"),
        _ => panic!("Invalid armour index: {}", index)
    }
}
