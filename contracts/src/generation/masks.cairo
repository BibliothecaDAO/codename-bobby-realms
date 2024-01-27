use blob::generation::traits::masks;

const TRAIT_COUNT: u32 = 9;

fn get_masks(seed: u32) -> ByteArray {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => masks::blobert(),
        1 => masks::doge(),
        2 => masks::dojo(),
        3 => masks::ducks(),
        4 => masks::influence(),
        5 => masks::kevin(),
        6 => masks::milady(),
        7 => masks::pepe(),
        8 => masks::pudgy(),
        9 => masks::smol(),
        _ => panic!("Invalid trait value"),
    }
}
