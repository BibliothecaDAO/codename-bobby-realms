use blob::generation::traits::background;


fn backgrounds() -> Array<(ByteArray, ByteArray)> {
    return array![
            (background::blue(), "Blue"),
            (background::cryptsandcaverns(), "Crypts and Caverns"),
            (background::fidenza(), "Fidenza"),
            (background::green(), "Green"),
            (background::holo(), "Holo"),
            (background::orange(), "Orange"),
            (background::purple(), "Purple"),
            (background::realms(), "Realms"),
            (background::terraforms(), "Terraforms")
        ];
}
