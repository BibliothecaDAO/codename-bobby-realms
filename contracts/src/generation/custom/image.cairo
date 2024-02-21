use blob::generation::custom::data::images;


const CUSTOM_IMAGES_COUNT: u8 = 48;

fn custom_images(index: u8) -> (ByteArray, ByteArray) {
    let index: felt252 = index.into();

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
        20 => (images::bulbert(), "Bulbert"),
        21 => (images::devbert(), "Devbert"),
        22 => (images::blobhetti(), "Blobhetti"),
        23 => (images::hambert(), "Hambert"),
        24 => (images::calbert(), "Calbert"),
        25 => (images::raubert(), "Raubert"),
        26 => (images::tbert(), "Tbert"),
        27 => (images::_1337bert(), "1337bert"),
        28 => (images::mirbert(), "Mirbert"),
        29 => (images::credbert(), "Credbert"),
        30 => (images::redbert(), "Redbert"),
        31 => (images::pleurbert(), "Pleurbert"),
        32 => (images::shelbert(), "Shelbert"),
        33 => (images::rebert(), "Rebert"),
        34 => (images::lootbert(), "Lootbert"),
        35 => (images::breadbert(), "Breadbert"),
        36 => (images::grugbert(), "Grugbert"),
        37 => (images::duckbert(), "Duckbert"),
        38 => (images::wenbert(), "Wenbert"),
        39 => (images::guthbert(), "Guthbert"),
        40 => (images::moodbert(), "Moodbert"),
        41 => (images::francaisbert(), "Francaisbert"),
        42 => (images::odbert(), "Odbert"),
        // to be won in mint lottery
        43 => (images::butterbert(), "Butterbert"),
        44 => (images::bobbyrealms(), "Bobby Realms"),
        45 => (images::goldbert(), "Goldbert"),
        46 => (images::GOATbert(), "GOATbert"),
        47 => (images::blobert(), "Genesis Blobert"),
        _ => panic!("wrong image index")
    }
}

