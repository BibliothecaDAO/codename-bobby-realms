use blob::generation::traits::masks;

const TRAIT_COUNT: u32 = 9;

fn get_masks(seed: u32) -> (ByteArray, ByteArray) {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => (masks::blobert(), "Blobert"),
        1 => (masks::doge(), "Doge"),
        2 => (masks::dojo(), "Dojo"),
        3 => (masks::ducks(), "Ducks"),
        4 => (masks::influence(), "Influence"),
        5 => (masks::kevin(), "Kevin"),
        6 => (masks::milady(), "Milady"),
        7 => (masks::pepe(), "Pepe"),
        8 => (masks::pudgy(), "Pudgy"),
        9 => (masks::smol(), "Smol"),
        _ => panic!("Invalid trait value"),
    }
}
