use blob::generation::traits::data::jewelry;

const JEWELRY_COUNT: u8 = 8;
fn jewellries(index: u8) -> (ByteArray, ByteArray) {
    assert(index < JEWELRY_COUNT, 'wrong jewelry index');
    let index: felt252 = index.into();

    match index {
        0 => (jewelry::amulet(), "Amulet"),
        1 => (jewelry::bronze_ring(), "Bronze Ring"),
        2 => (jewelry::gold_ring(), "Gold Ring"),
        3 => (jewelry::necklace(), "Necklace"),
        4 => (jewelry::pendant(), "Pendant"),
        5 => (jewelry::platinum_ring(), "Platinum Ring"),
        6 => (jewelry::silver_ring(), "Silver Ring"),
        7 => (jewelry::titanium_ring(), "Titanium Ring"),
        _ => panic!("wrong jewelry index")
    }
}
