use blob::generation::traits::weapon;

const WEAPON_COUNT: u32 = 12;
fn weapons(index: u32) -> (ByteArray, ByteArray) {
    assert(index < WEAPON_COUNT, 'wrong weapon index');
    let index: felt252 = index.into();

    match index {
        0 => (weapon::balloons(), "Balloons"),
        1 => (weapon::banner(), "Banner"),
        2 => (weapon::briq(), "Briq"),
        3 => (weapon::callthebanners(), "Call the Banners"),
        4 => (weapon::diamondhands(), "Diamond Hands"),
        5 => (weapon::dopeuzi(), "Dope Uzi"),
        6 => (weapon::ghostwand(), "Ghost Wand"),
        7 => (weapon::grimoire(), "Grimoire"),
        8 => (weapon::katana(), "Katana"),
        9 => (weapon::starkmagic(), "Stark Magic"),
        10 => (weapon::starkshield(), "Stark Shield"),
        11 => (weapon::warhammer(), "Warhammer"),
        _ => panic!("wrong weapon index")
    }
}
