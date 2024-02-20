use blob::generation::traits::data::weapon;

const WEAPON_COUNT: u8 = 43;
fn weapons(index: u8) -> (ByteArray, ByteArray) {
    assert(index < WEAPON_COUNT, 'wrong weapon index');
    let index: felt252 = index.into();

    match index {
        0 => (weapon::algorithmic_aegis(), "Algorithmic Aegis"),
        1 => (weapon::argent_shield(), "Argent Shield"),
        2 => (weapon::balloons(), "Balloons"),
        3 => (weapon::banner_of_anger(), "Banner of Anger"),
        4 => (weapon::banner_of_brilliance(), "Banner of Brilliance"),
        5 => (weapon::banner_of_detection(), "Banner of Detection"),
        6 => (weapon::banner_of_enlightenment(), "Banner of Enlightenment"),
        7 => (weapon::banner_of_fury(), "Banner of Fury"),
        8 => (weapon::banner_of_giants(), "Banner of Giants"),
        9 => (weapon::banner_of_perfection(), "Banner of Perfection"),
        10 => (weapon::banner_of_power(), "Banner of Power"),
        11 => (weapon::banner_of_protection(), "Banner of Protection"),
        12 => (weapon::banner_of_rage(), "Banner of Rage"),
        13 => (weapon::banner_of_reflection(), "Banner of Reflection"),
        14 => (weapon::banner_of_skill(), "Banner of Skill"),
        15 => (weapon::banner_of_the_fox(), "Banner of The Fox"),
        16 => (weapon::banner_of_the_twins(), "Banner of The Twins"),
        17 => (weapon::banner_of_titans(), "Banner of Titans"),
        18 => (weapon::banner_of_tony_hawk(), "Banner of Tony Hawk"),
        19 => (weapon::banner_of_vitriol(), "Banner of Vitriol"),
        20 => (weapon::banner(), "Banner"),
        21 => (weapon::briq(), "Briq"),
        22 => (weapon::calculator(), "Calculator"),
        23 => (weapon::devving_for_the_distracted(), "Devving for The Distracted"),
        24 => (weapon::diamond_hands(), "Diamond Hands"),
        25 => (weapon::dope_uzi(), "Dope Uzi"),
        26 => (weapon::ghost_wand(), "Ghost Wand"),
        27 => (weapon::grimoire(), "Grimoire"),
        28 => (weapon::grugs_club(), "Grugs Club"),
        29 => (weapon::jediswap_saber(), "Jediswap Saber"),
        30 => (weapon::katana(), "Katana"),
        31 => (weapon::lords_banner(), "Lords Banner"),
        32 => (weapon::ls_has_no_chill(), "Ls has no chill"),
        33 => (weapon::mandolin(), "Mandolin"),
        34 => (weapon::sign_iso(), "Sign Iso"),
        35 => (weapon::signature_banner(), "Signature Banner"),
        36 => (weapon::sithswap_saber(), "Sithswap Saber"),
        37 => (weapon::spaghetti(), "Spaghetti"),
        38 => (weapon::squid(), "Squid"),
        39 => (weapon::stark_magic(), "Stark Magic"),
        40 => (weapon::stark_shield(), "Stark Shield"),
        41 => (weapon::stool(), "Stool"),
        42 => (weapon::warhammer(), "Warhammer"),
        _ => panic!("wrong weapon index")
    }
}
