use blob::generation::traits::background;

const TRAIT_COUNT: u32 = 8;

fn get_background(seed: u32) -> ByteArray {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => background::blue(),
        1 => background::cryptsandcaverns(),
        2 => background::fidenza(),
        3 => background::green(),
        4 => background::holo(),
        5 => background::orange(),
        6 => background::purple(),
        7 => background::realms(),
        8 => background::terraforms(),
        _ => panic!("Invalid trait value"),
    }
}
