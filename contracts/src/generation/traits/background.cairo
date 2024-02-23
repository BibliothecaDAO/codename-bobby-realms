use blob::generation::traits::data::background;

const BACKGROUND_COUNT: u8 = 12;
fn backgrounds(index: u8) -> (ByteArray, ByteArray) {
    assert(index < BACKGROUND_COUNT, 'wrong background index');
    let index: felt252 = index.into();

    match index {
        0 => (background::avnu_blue(), "Avnu Blue"),
        1 => (background::blue(), "Blue"),
        2 => (background::crypts_and_caverns(), "Crypts and Caverns"),
        3 => (background::fibrous_frame(), "Fibrous Frame"),
        4 => (background::green(), "Green"),
        5 => (background::holo(), "Holo"),
        6 => (background::orange(), "Orange"),
        7 => (background::purple(), "Purple"),
        8 => (background::realms_dark(), "Realms Dark"),
        9 => (background::realms(), "Realms"),
        10 => (background::terraforms(), "Terraforms"),
        11 => (background::tulip(), "Tulip"),
        _ => panic!("wrong background index")
    }
}
