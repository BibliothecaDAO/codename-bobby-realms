mod descriptor {
    #[derive(Copy, Drop, Serde)]
    enum ImageType {
        Svg,
        Base64Encoded
    }
}

mod seeder {
    use starknet::{StorePacking};

    #[derive(Copy, Drop, Serde, Hash)]
    struct Seed {
        background: u8,
        armour: u8,
        jewellry: u8,
        mask: u8,
        weapon: u8,
    }


    const TWO_POW_8: u64 = 0x100;
    const TWO_POW_16: u64 = 0x10000;
    const TWO_POW_24: u64 = 0x1000000;
    const TWO_POW_32: u64 = 0x100000000;

    const MASK_8: u64 = 0xff;


    impl SeedStorePacking of StorePacking<Seed, u64> {
        fn pack(value: Seed) -> u64 {
            value.background.into()
                + (value.armour.into() * (TWO_POW_8))
                + (value.jewellry.into() * (TWO_POW_16))
                + (value.mask.into() * (TWO_POW_24))
                + (value.weapon.into() * (TWO_POW_32))
        }

        fn unpack(value: u64) -> Seed {
            Seed {
                background: (value & MASK_8).try_into().unwrap(),
                armour: ((value / TWO_POW_8) & MASK_8).try_into().unwrap(),
                jewellry: ((value / TWO_POW_16) & MASK_8).try_into().unwrap(),
                mask: ((value / TWO_POW_24) & MASK_8).try_into().unwrap(),
                weapon: (value / TWO_POW_32).try_into().unwrap()
            }
        }
    }
}


mod erc721 {
    #[derive(Copy, Drop, Serde)]
    enum WhitelistClass {
        Dev,
        RealmHolder
    }
}
