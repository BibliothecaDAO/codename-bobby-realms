use blob::generation::traits::data::jewelry;

const jewelry_COUNT: u8 = 9;
fn jewellries(index: u8) -> (ByteArray, ByteArray) {
    assert(index < jewelry_COUNT, 'wrong jewelry index');
    let index: felt252 = index.into();

    match index {
        0 => (jewelry::amulet(), "Amulet"),
        1 => (jewelry::bronzering(), "Bronze Ring"),
        2 => (jewelry::goldring(), "Gold Ring"),
        3 => (jewelry::necklace(), "Necklace"),
        4 => (jewelry::nounsglasses(), "Nouns Glasses"),
        5 => (jewelry::pendant(), "Pendant"),
        6 => (jewelry::platinumring(), "Platinum Ring"),
        7 => (jewelry::silverring(), "Silver Ring"),
        8 => (jewelry::titaniumring(), "Titanium Ring"),
        _ => panic!("wrong jewelry index")
    }
}
