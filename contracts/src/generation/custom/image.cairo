use blob::generation::custom::data::image;


const CUSTOM_IMAGES_COUNT: u8 = 50;

fn custom_images_0_19(index: u8) -> (ByteArray, ByteArray) {
    assert(index >= 0, 'wrong custom img index (2)');
    assert(index <= 19, 'wrong custom img index (2)');
    let index: felt252 = index.into()  - 0 ;

    match index {
        0 => (image::french0(), "French"),
        1 => (image::french1(), "French"),
        2 => (image::french2(), "French"),
        3 => (image::french3(), "French"),
        4 => (image::french4(), "French"),
        5 => (image::french5(), "French"),
        6 => (image::french6(), "French"),
        7 => (image::french7(), "French"),
        8 => (image::french8(), "French"),
        9 => (image::french9(), "French"),
        10 => (image::french10(), "French"),
        11 => (image::french11(), "French"),
        12 => (image::french12(), "French"),
        13 => (image::french13(), "French"),
        14 => (image::french14(), "French"),
        15 => (image::french15(), "French"),
        16 => (image::french16(), "French"),
        17 => (image::french17(), "French"),
        18 => (image::french18(), "French"),
        19 => (image::french19(), "French"),
        _ => panic!("wrong image index")
    }
}


fn custom_images_20_39(index: u8) -> (ByteArray, ByteArray) {
    assert(index >= 20, 'wrong custom img index (2)');
    assert(index <= 39, 'wrong custom img index (2)');
    let index: felt252 = index.into()  - 20;

    match index {
        0 => (image::french20(), "French"),
        1 => (image::french21(), "French"),
        2 => (image::french22(), "French"),
        3 => (image::french23(), "French"),
        4 => (image::french24(), "French"),
        5 => (image::french25(), "French"),
        6 => (image::french26(), "French"),
        7 => (image::french27(), "French"),
        8 => (image::french28(), "French"),
        9 => (image::french29(), "French"),
        10 => (image::french30(), "French"),
        11 => (image::french31(), "French"),
        12 => (image::french32(), "French"),
        13 => (image::french33(), "French"),
        14 => (image::french34(), "French"),
        15 => (image::french35(), "French"),
        16 => (image::french36(), "French"),
        17 => (image::french37(), "French"),
        18 => (image::french38(), "French"),
        19 => (image::french39(), "French"),
        _ => panic!("wrong image index")
    }
}


fn custom_images_40_49(index: u8) -> (ByteArray, ByteArray) {
    assert(index >= 40, 'wrong custom img index (3)');
    assert(index <= 49, 'wrong custom img index (3)');
    let index: felt252 = index.into()  - 40;

    match index {
        0 => (image::french40(), "French"),
        1 => (image::french41(), "French"),
        2 => (image::french42(), "French"),
        3 => (image::french43(), "French"),
        4 => (image::french44(), "French"),
        5 => (image::french45(), "French"),
        6 => (image::french46(), "French"),
        7 => (image::french47(), "French"),
        8 => (image::french48(), "French"),
        9 => (image::french49(), "French"),
        _ => panic!("wrong image index")
    }
}


