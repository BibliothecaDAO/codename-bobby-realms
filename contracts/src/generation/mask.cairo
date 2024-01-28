use blob::generation::traits::mask;


const MASK_COUNT: u32 = 10;
fn masks(index: u32) -> (ByteArray, ByteArray) {

    assert(index < MASK_COUNT, 'wrong mask index');
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
