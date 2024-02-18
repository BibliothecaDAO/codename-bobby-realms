use blob::generation::traits::data::mask;


const CUSTOM_IMAGES_COUNT: u8 = 50;
fn custom_images(index: u8) -> (ByteArray, ByteArray) {
    assert(index < CUSTOM_IMAGES_COUNT, 'wrong custom img index');
    let index: felt252 = index.into();

    match index {
        0 => (mask::blobert(), "Blobert"),
        1 => (mask::doge(), "Doge"),
        2 => (mask::dojo(), "Dojo"),
        3 => (mask::ducks(), "Ducks"),
        4 => (mask::influence(), "Influence"),
        5 => (mask::kevin(), "Kevin"),
        6 => (mask::milady(), "Milady"),
        7 => (mask::pepe(), "Pepe"),
        8 => (mask::pudgy(), "Pudgy"),
        9 => (mask::smol(), "Smol"),
        10 => (mask::smol(), "Smol"),
        11 => (mask::smol(), "Smol"),
        12 => (mask::smol(), "Smol"),
        13 => (mask::smol(), "Smol"),
        14 => (mask::smol(), "Smol"),
        15 => (mask::milady(), "Milady"),
        16 => (mask::smol(), "Smol"),
        17 => (mask::smol(), "Smol"),
        18 => (mask::smol(), "Smol"),
        19 => (mask::smol(), "Smol"),
        20 => (mask::smol(), "Smol"),
        21 => (mask::smol(), "Smol"),
        22 => (mask::smol(), "Smol"),
        23 => (mask::smol(), "Smol"),
        24 => (mask::smol(), "Smol"),
        25 => (mask::smol(), "Smol"),
        26 => (mask::smol(), "Smol"),
        27 => (mask::smol(), "Smol"),
        28 => (mask::smol(), "Smol"),
        29 => (mask::smol(), "Smol"),
        30 => (mask::smol(), "Smol"),
        31 => (mask::smol(), "Smol"),
        32 => (mask::smol(), "Smol"),
        33 => (mask::smol(), "Smol"),
        34 => (mask::smol(), "Smol"),
        35 => (mask::smol(), "Smol"),
        36 => (mask::smol(), "Smol"),
        37 => (mask::smol(), "Smol"),
        38 => (mask::milady(), "Milady"),
        39 => (mask::smol(), "Smol"),
        40 => (mask::smol(), "Smol"),
        41 => (mask::smol(), "Smol"),
        42 => (mask::smol(), "Smol"),
        43 => (mask::smol(), "Smol"),
        44 => (mask::smol(), "Smol"),
        45 => (mask::smol(), "Smol"),
        46 => (mask::smol(), "Smol"),
        47 => (mask::smol(), "Smol"),
        48 => (mask::smol(), "Smol"),
        49 => (mask::milady(), "Milady"),
        _ => panic!("wrong mask index")
    }
}
