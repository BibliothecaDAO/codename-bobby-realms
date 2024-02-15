use blob::generation::traits::data::mask;


const SPECIAL_IMAGES_COUNT: u8 = 10;
fn special_images(index: u8) -> (ByteArray, ByteArray) {
    assert(index < SPECIAL_IMAGES_COUNT, 'wrong special img index');
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
        _ => panic!("wrong mask index")
    }
}
