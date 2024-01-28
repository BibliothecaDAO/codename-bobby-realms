use blob::generation::traits::armour;

const TRAIT_COUNT: u32 = 8;

fn get_armour(seed: u32) -> (ByteArray, ByteArray) {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => (armour::chainmail(), "Chain Mail"),
        1 => (armour::demonarmour(), "Chain Mail"),
        2 => (armour::divinerobe(), "Chain Mail"),
        3 => (armour::kigurumi(), "Chain Mail"),
        4 => (armour::leatherarmour(), "Chain Mail"),
        5 => (armour::platemail(), "Chain Mail"),
        6 => (armour::robe(), "Chain Mail"),
        7 => (armour::sheepswool(), "Chain Mail"),
        8 => (armour::underpants(), "Chain Mail"),
        _ => panic!("Invalid trait value"),
    }
}
