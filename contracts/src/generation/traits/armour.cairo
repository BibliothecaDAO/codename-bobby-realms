use blob::generation::traits::data::armour;

const ARMOUR_COUNT: u8 = 17;
fn armours(index: u8) -> (ByteArray, ByteArray) {
    assert(index < ARMOUR_COUNT, 'wrong armour index');

    let index: felt252 = index.into();

    match index {
        0 => (armour::sheeps_wool(), "Sheeps Wool"),
        1 => (armour::kigurumi(), "Kigurumi"),
        2 => (armour::divine_robe_dark(), "Divine Robe Dark"),
        3 => (armour::divine_robe(), "Divine Robe"),
        4 => (armour::dojo_robe(), "Dojo Robe"),
        5 => (armour::holy_chestplate(), "Holy Chestplate"),
        6 => (armour::demon_husk(), "Demon Husk"),
        7 => (armour::leather_armour(), "Leather Armour"),
        8 => (armour::leopard_skin(), "Leopard Skin"),
        9 => (armour::linen_robe(), "Linen Robe"),
        10 => (armour::lords_armor(), "Lords Armor"),
        11 => (armour::secret_tattoo(), "Secret Tattoo"),
        12 => (armour::chainmail(), "Chainmail"),
        13 => (armour::suit(), "Suit"),
        14 => (armour::underpants(), "Underpants"),
        15 => (armour::wen_shirt(), "Wen Shirt"),
        16 => (armour::wsb_tank_top(), "Wsb Tank Top"),
        _ => panic!("Invalid armour index: {}", index)
    }
}
