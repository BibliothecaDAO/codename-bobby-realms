use blob::generation::traits::weapons;

const TRAIT_COUNT: u32 = 11;

fn get_weapon(seed: u32) -> ByteArray {
    let value = seed % TRAIT_COUNT;

    println!("Armour: {}", value);

    match value {
        0 => weapons::balloons(),
        1 => weapons::banner(),
        2 => weapons::briq(),
        3 => weapons::callthebanners(),
        4 => weapons::diamondhands(),
        5 => weapons::dopeuzi(),
        6 => weapons::ghostwand(),
        7 => weapons::grimoire(),
        8 => weapons::katana(),
        9 => weapons::starkmagic(),
        10 => weapons::starkshield(),
        11 => weapons::warhammer(),
        _ => panic!("Invalid trait value"),
    }
}
