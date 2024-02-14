mod descriptor {
    #[derive(Copy, Drop, Serde)]
    enum ImageType {
        Svg,
        Base64Encoded
    }
}

mod seeder {
    #[derive(Copy, Drop, Serde, Hash, starknet::Store)]
    struct Seed {
        background: u32,
        armour: u32,
        jewellry: u32,
        mask: u32,
        weapon: u32,
    }
}


mod erc721 {
    #[derive(Copy, Drop, Serde)]
    enum WhitelistClass {
        Dev,
        RealmHolder
    }
}
