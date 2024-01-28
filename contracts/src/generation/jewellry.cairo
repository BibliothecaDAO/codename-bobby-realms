use blob::generation::traits::jewellry;

const TRAIT_COUNT: u32 = 8;

fn get_jewellry(seed: u32) -> (ByteArray, ByteArray) {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => (jewellry::amulet(), "Amulet"),
        1 => (jewellry::bronzering(), "Bronze Ring"),
        2 => (jewellry::goldring(), "Gold Ring"),
        3 => (jewellry::necklace(), "Necklace"),
        4 => (jewellry::nounsglasses(), "Nouns Glasses"),
        5 => (jewellry::pendant(), "Pendant"),
        6 => (jewellry::platinumring(), "Platinum Ring"),
        7 => (jewellry::silverring(), "Silver Ring"),
        8 => (jewellry::titaniumring(), "Titanium Ring"),
        _ => panic!("Invalid trait value"),
    }
}
