use blob::generation::traits::data::mask;


const MASK_COUNT: u8 = 26;
fn masks(index: u8) -> (ByteArray, ByteArray) {
    assert(index < MASK_COUNT, 'wrong mask index');
    let index: felt252 = index.into();

    match index {
        0 => (mask::blobert(), "Blobert"),
        1 => (mask::doge(), "Doge"),
        2 => (mask::dojo(), "Dojo"),
        3 => (mask::ducks(), "Ducks"),
        4 => (mask::kevin(), "Kevin"),
        5 => (mask::milady(), "Milady"),
        6 => (mask::pepe(), "Pepe"),
        7 => (mask::pudgy(), "Pudgy"),
        8 => (mask::_3d_glasses(), "3d glasses"),
        9 => (mask::_1337_skulls(), "1337 Skulls"),
        10 => (mask::ancient_helm(), "Ancient Helm"),
        11 => (mask::bane(), "Bane"),
        12 => (mask::braavos_helm(), "Braavos Helm"),
        13 => (mask::bulbhead(), "Bulbhead"),
        14 => (mask::deal_with_it_glasses(), "Deal With It Glasses"),
        15 => (mask::demon_crown(), "Demon Crown"),
        16 => (mask::divine_hood(), "Divine Hood"),
        17 => (mask::ekubo(), "Ekubo"),
        18 => (mask::hyperloot_crown(), "Hyperloot Crown"),
        19 => (mask::influence_helmet(), "Influence Helmet"),
        20 => (mask::lords_helm(), "Lords Helm"),
        21 => (mask::nostrahat(), "Nostrahat"),
        22 => (mask::nouns_glasses(), "Nouns Glasses"),
        23 => (mask::pope_hat(), "Pope Hat"),
        24 => (mask::taproot_wizard_hat(), "Taproot Wizard Hat"),
        25 => (mask::wif_hat(), "Wif Hat"),
        _ => panic!("wrong mask index")
    }
}
