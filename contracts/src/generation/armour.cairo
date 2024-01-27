use blob::generation::traits::armour;

const TRAIT_COUNT: u32 = 8;

fn get_armour(seed: u32) -> ByteArray {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => armour::chainmail(),
        1 => armour::demonarmour(),
        2 => armour::divinerobe(),
        3 => armour::kigurumi(),
        4 => armour::leatherarmour(),
        5 => armour::platemail(),
        6 => armour::robe(),
        7 => armour::sheepswool(),
        8 => armour::underpants(),
        _ => panic!("Invalid trait value"),
    }
}
