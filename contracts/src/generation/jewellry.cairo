use blob::generation::traits::jewellry;

const TRAIT_COUNT: u32 = 8;

fn get_jewellry(seed: u32) -> ByteArray {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => jewellry::amulet(),
        1 => jewellry::bronzering(),
        2 => jewellry::goldring(),
        3 => jewellry::necklace(),
        4 => jewellry::nounsglasses(),
        5 => jewellry::pendant(),
        6 => jewellry::platinumring(),
        7 => jewellry::silverring(),
        8 => jewellry::titaniumring(),
        _ => panic!("Invalid trait value"),
    }
}
