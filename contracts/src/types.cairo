mod descriptor {
    #[derive(Copy, Drop, Serde)]
    enum ImageType {
        Svg,
        Base64Encoded
    }
}

mod seeder {
    use starknet::{StorePacking};


    #[derive(Copy, Drop, Serde, Hash, PartialEq)]
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
    use starknet::{StorePacking};
    use super::seeder::Seed;


    #[derive(Copy, Drop, Serde)]
    enum WhitelistTier {
        One,
        Two, 
        Three, 
        Four, 
        Five
    }


    #[derive(Copy, Drop, Serde, PartialEq)]
    enum TokenIdentifier {
        RegularTokenSeed: Seed,
        CustomTokenIndex: u8
    }


    #[derive(Copy, Drop, Serde, PartialEq)]
    struct MintStartTime {
        regular: u64,
        whitelist: u64
    }


    const TWO_POW_64: u128 = 0x10000000000000000;
    const MASK_64: u128 = 0xffffffffffffffff;

    impl MintStartTimeStorePacking of StorePacking<MintStartTime, u128> {
        fn pack(value: MintStartTime) -> u128 {
            value.regular.into()
                + (value.whitelist.into() * TWO_POW_64)
        }

        fn unpack(value: u128) -> MintStartTime {
            MintStartTime {
                regular: (value & MASK_64).try_into().unwrap(),
                whitelist: (value / TWO_POW_64).try_into().unwrap()
            }
        }
    }



    #[derive(Copy, Drop, Serde, PartialEq)]
    struct Supply {
        total_nft: u16,
        custom_nft: u8
    }

    const TWO_POW_16: u32 = 0x10000;
    const MASK_16: u32 = 0xffff;

    impl SupplyStorePacking of StorePacking<Supply, u32> {
        fn pack(value: Supply) -> u32 {
            value.total_nft.into()
                + (value.custom_nft.into() * TWO_POW_16)
        }

        fn unpack(value: u32) -> Supply {
            Supply {
                total_nft: (value & MASK_16).try_into().unwrap(),
                custom_nft: (value / TWO_POW_16).try_into().unwrap()
            }
        }
    }

}
