use blob::generation::custom::data::images;


const CUSTOM_IMAGES_COUNT: u8 = 48;

fn custom_images_0_19(index: u8) -> (ByteArray, ByteArray) {
    assert(index >= 0, 'wrong custom img index (2)');
    assert(index <= 19, 'wrong custom img index (2)');
    let index: felt252 = index.into() - 0;

    match index {
        0 => (images::udbert(), "Udbert"),
        1 => (images::erbert(), "Erbert"),
        2 => (images::milbert(), "Milbert"),
        3 => (images::dombert(), "Dombert"),
        4 => (images::STARKbert(), "STARKbert"),
        5 => (images::delbert(), "Delbert"),
        6 => (images::nejbert(), "Nejbert"),
        7 => (images::tarbert(), "Tarbert"),
        8 => (images::sylbert(), "Sylbert"),
        9 => (images::lanbert(), "Lanbert"),
        10 => (images::neobert(), "Neobert"),
        11 => (images::tenbert(), "Tenbert"),
        12 => (images::sebert(), "Sebert"),
        13 => (images::gobert(), "Gobert"),
        14 => (images::casbert(), "Casbert"),
        15 => (images::fombert(), "Fombert"),
        16 => (images::ambert(), "Ambert"),
        17 => (images::chelbert(), "Chelbert"),
        18 => (images::pobert(), "Pobert"),
        19 => (images::squibert(), "Squibert"),
        _ => panic!("wrong image index")
    }
}


fn custom_images_20_39(index: u8) -> (ByteArray, ByteArray) {
    assert(index >= 20, 'wrong custom img index (2)');
    assert(index <= 39, 'wrong custom img index (2)');
    let index: felt252 = index.into() - 20;

    match index {
        0 => (images::bulbert(), "Bulbert"),
        1 => (images::devbert(), "Devbert"),
        2 => (images::blobhetti(), "Blobhetti"),
        3 => (images::hambert(), "Hambert"),
        4 => (images::calbert(), "Calbert"),
        5 => (images::raubert(), "Raubert"),
        6 => (images::tbert(), "Tbert"),
        7 => (images::_1337bert(), "1337bert"),
        8 => (images::mirbert(), "Mirbert"),
        9 => (images::credbert(), "Credbert"),
        10 => (images::redbert(), "Redbert"),
        11 => (images::pleurbert(), "Pleurbert"),
        12 => (images::shelbert(), "Shelbert"),
        13 => (images::rebert(), "Rebert"),
        14 => (images::lootbert(), "Lootbert"),
        15 => (images::breadbert(), "Breadbert"),
        16 => (images::grugbert(), "Grugbert"),
        17 => (images::duckbert(), "Duckbert"),
        18 => (images::wenbert(), "Wenbert"),
        19 => (images::guthbert(), "Guthbert"),
        _ => panic!("wrong image index")
    }
}


fn custom_images_40_47(index: u8) -> (ByteArray, ByteArray) {
    assert(index >= 40, 'wrong custom img index (3)');
    assert(index <= 47, 'wrong custom img index (3)');
    let index: felt252 = index.into() - 40;

    match index {
        0 => (images::moodbert(), "Moodbert"),
        1 => (images::francaisbert(), "Francaisbert"),
        2 => (images::odbert(), "Odbert"),
        // to be won in mint lottery
        3 => (images::butterbert(), "Butterbert"),
        4 => (images::bobbyrealms(), "Bobby Realms"),
        5 => (images::goldbert(), "Goldbert"),
        6 => (images::GOATbert(), "GOATbert"),
        7 => (images::blobert(), "Blobert"),
        _ => panic!("wrong image index")
    }
}

