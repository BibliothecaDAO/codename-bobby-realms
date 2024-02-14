use blob::generation::traits::background;

const BACKGROUND_COUNT: u32 = 9;
fn backgrounds(index: u32) -> (ByteArray, ByteArray) {
    assert(index < BACKGROUND_COUNT, 'wrong background index');
    let index: felt252 = index.into();

    match index {
        0 => (background::blue(), "Blue"),
        1 => (background::cryptsandcaverns(), "Crypts and Caverns"),
        2 => (background::fidenza(), "Fidenza"),
        3 => (background::green(), "Green"),
        4 => (background::holo(), "Holo"),
        5 => (background::orange(), "Orange"),
        6 => (background::purple(), "Purple"),
        7 => (background::realms(), "Realms"),
        8 => (background::terraforms(), "Terraforms"),
        _ => panic!("wrong background index")
    }
}
