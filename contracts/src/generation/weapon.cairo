use blob::generation::traits::weapon;

fn weapons() -> Array<(ByteArray, ByteArray)> {

    return array![
        (weapon::balloons(), "Balloons"),
        (weapon::banner(), "Banner"),
        (weapon::briq(), "Briq"),
        (weapon::callthebanners(), "Call the Banners"),
        (weapon::diamondhands(), "Diamond Hands"),
        (weapon::dopeuzi(), "Dope Uzi"),
        (weapon::ghostwand(), "Ghost Wand"),
        (weapon::grimoire(), "Grimoire"),
        (weapon::katana(), "Katana"),
        (weapon::starkmagic(), "Stark Magic"),
        (weapon::starkshield(), "Stark Shield"),
        (weapon::warhammer(), "Warhammer")
    ];
}