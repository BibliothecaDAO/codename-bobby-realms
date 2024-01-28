use blob::generation::traits::jewellry;

fn jewellries() -> Array<(ByteArray, ByteArray)> {
    return array![
            (jewellry::amulet(), "Amulet"),
            (jewellry::bronzering(), "Bronze Ring"),
            (jewellry::goldring(), "Gold Ring"),
            (jewellry::necklace(), "Necklace"),
            (jewellry::nounsglasses(), "Nouns Glasses"),
            (jewellry::pendant(), "Pendant"),
            (jewellry::platinumring(), "Platinum Ring"),
            (jewellry::silverring(), "Silver Ring"),
            (jewellry::titaniumring(), "Titanium Ring")
        ];
}