use blob::generation::traits::background;

const TRAIT_COUNT: u32 = 8;

fn get_background(seed: u32) -> (ByteArray, ByteArray) {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => (background::blue(), "Blue"),
        1 => (background::cryptsandcaverns(), "Crypts and Caverns"),
        2 => (background::fidenza(), "Fidenza"),
        3 => (background::green(), "Green"),
        4 => (background::holo(), "Holo"),
        5 => (background::orange(), "Orange"),
        6 => (background::purple(), "Purple"),
        7 => (background::realms(), "Realms"),
        8 => (background::terraforms(), "Terraforms"),
        _ => panic!("Invalid trait value"),
    }
}
