use blob::generation::traits::armour;


fn armours() -> Array<(ByteArray, ByteArray)> {
    return array![
            (armour::chainmail(), "Chainmail"),
            (armour::demonarmour(), "Demon Armour"),
            (armour::divinerobe(), "Divine Robe"),
            (armour::kigurumi(), "Kigurumi"),
            (armour::leatherarmour(), "Leather Armour"),
            (armour::platemail(), "Plate Mail"),
            (armour::robe(), "Robe"),
            (armour::sheepswool(), "Sheep's Wool"),
            (armour::underpants(), "Underpants")
    ];
}
