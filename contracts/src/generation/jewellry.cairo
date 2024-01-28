use blob::generation::traits::jewellry;

const JEWELLRY_COUNT: u32 = 9;
fn jewellries(index: u32) -> (ByteArray, ByteArray) {

    assert(index < JEWELLRY_COUNT, 'wrong jewellry index');
    let index: felt252 = index.into();

    match index {
        0 => (jewellry::amulet(), "Amulet"),
        1 => (jewellry::bronzering(), "Bronze Ring"),
        2 => (jewellry::goldring(), "Gold Ring"),
        3 => (jewellry::necklace(), "Necklace"),
        4 => (jewellry::nounsglasses(), "Nouns Glasses"),
        5 => (jewellry::pendant(), "Pendant"),
        6 => (jewellry::platinumring(), "Platinum Ring"),
        7 => (jewellry::silverring(), "Silver Ring"),
        8 => (jewellry::titaniumring(), "Titanium Ring"),
        _ => panic!("wrong jewellry index")
    }
}
