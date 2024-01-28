use blob::generation::traits::weapons;

const TRAIT_COUNT: u32 = 11;

fn get_weapon(seed: u32) -> (ByteArray, ByteArray) {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => (weapons::balloons(), "Ballons"),
        1 => (weapons::banner(), "Banner"),
        2 => (weapons::briq(), "Briq"),
        3 => (weapons::callthebanners(), "Call the Banners"),
        4 => (weapons::diamondhands(), "Diamond Hands"),
        5 => (weapons::dopeuzi(), "Dope Uzi"),
        6 => (weapons::ghostwand(), "Ghost Wand"),
        7 => (weapons::grimoire(), "Grimoire"),
        8 => (weapons::katana(), "Katana"),
        9 => (weapons::starkmagic(), "Stark Magic"),
        10 => (weapons::starkshield(), "Stark Shield"),
        11 => (weapons::warhammer(), "Warhammer"),
        _ => panic!("Invalid trait value"),
    }
}
