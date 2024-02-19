use blob::types::descriptor::RenderType;
use blob::types::seeder::Seed;

#[starknet::interface]
trait IDescriptorRegular<TContractState> {
    fn armour_count(self: @TContractState) -> u8;
    fn armour(self: @TContractState, index: u8) -> (ByteArray, ByteArray);

    fn background_count(self: @TContractState) -> u8;
    fn background(self: @TContractState, index: u8) -> (ByteArray, ByteArray);

    fn jewelry_count(self: @TContractState) -> u8;
    fn jewelry(self: @TContractState, index: u8) -> (ByteArray, ByteArray);

    fn mask_count(self: @TContractState) -> u8;
    fn mask(self: @TContractState, index: u8) -> (ByteArray, ByteArray);

    fn weapon_count(self: @TContractState) -> u8;
    fn weapon(self: @TContractState, index: u8) -> (ByteArray, ByteArray);

    fn token_uri(self: @TContractState, token_id: u256, seed: Seed) -> ByteArray;
    fn svg_image(self: @TContractState, seed: Seed) -> ByteArray;
}


#[starknet::contract]
mod DescriptorRegular {
    use blob::generation::traits::{
        armour::{ARMOUR_COUNT}, mask::{MASK_COUNT}, background::{BACKGROUND_COUNT},
        jewelry::{jewelry_COUNT}, weapon::{WEAPON_COUNT}
    };
    use blob::generation::traits::{
        armour::{armours}, mask::{masks}, background::{backgrounds}, jewelry::{jewellries},
        weapon::{weapons}
    };
    use blob::types::descriptor::{ImageType, RenderType};
    use blob::types::seeder::Seed;
    use blob::utils::encoding::bytes_base64_encode;
    use core::array::ArrayTrait;
    use graffiti::json::JsonImpl;


    use graffiti::{Tag, TagImpl};
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;

    use starknet::ContractAddress;


    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl DescriptorRegularImpl of super::IDescriptorRegular<ContractState> {
        fn armour_count(self: @ContractState) -> u8 {
            return ARMOUR_COUNT;
        }

        fn armour(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            armours(index)
        }

        fn background_count(self: @ContractState) -> u8 {
            return BACKGROUND_COUNT;
        }

        fn background(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            backgrounds(index)
        }

        fn jewelry_count(self: @ContractState) -> u8 {
            return jewelry_COUNT;
        }

        fn jewelry(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            jewellries(index)
        }

        fn mask_count(self: @ContractState) -> u8 {
            return MASK_COUNT;
        }

        fn mask(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            masks(index)
        }

        fn weapon_count(self: @ContractState) -> u8 {
            return WEAPON_COUNT;
        }

        fn weapon(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            weapons(index)
        }

        fn token_uri(self: @ContractState, token_id: u256, seed: Seed) -> ByteArray {
            self.data_uri(token_id, seed)
        }

        fn svg_image(self: @ContractState, seed: Seed) -> ByteArray {
            let (armour_bytes, _) = armours(seed.armour);
            let (mask_bytes, _) = masks(seed.mask);
            let (background_bytes, _) = backgrounds(seed.background);
            let (jewelry_bytes, _) = jewellries(seed.jewelry);
            let (weapon_bytes, _) = weapons(seed.weapon);

            self
                .construct_image(
                    armour: armour_bytes,
                    mask: mask_bytes,
                    background: background_bytes,
                    jewelry: jewelry_bytes,
                    weapon: weapon_bytes,
                    image_type: RenderType::Svg
                )
        }
    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn data_uri(self: @ContractState, token_id: u256, seed: Seed) -> ByteArray {
            let (armour_bytes, armour_name) = armours(seed.armour);
            let (mask_bytes, mask_name) = masks(seed.mask);
            let (background_bytes, background_name) = backgrounds(seed.background);
            let (jewelry_bytes, jewelry_name) = jewellries(seed.jewelry);
            let (weapon_bytes, weapon_name) = weapons(seed.weapon);

            let image: ByteArray = self
                .construct_image(
                    armour: armour_bytes,
                    mask: mask_bytes,
                    background: background_bytes,
                    jewelry: jewelry_bytes,
                    weapon: weapon_bytes,
                    image_type: RenderType::Base64Encoded
                );

            let attributes: Span<ByteArray> = self
                .construct_attributes(
                    armour: armour_name,
                    mask: mask_name,
                    background: background_name,
                    jewelry: jewelry_name,
                    weapon: weapon_name
                );

            let type_: ByteArray = format!("{}", ImageType::REGULAR);

            let metadata: ByteArray = JsonImpl::new()
                .add("name", self.get_token_name(token_id))
                .add("description", self.get_token_description(token_id))
                .add("type", type_)
                .add("image", image)
                .add_array("attributes", attributes)
                .build();

            let base64_encoded_metadata: ByteArray = bytes_base64_encode(metadata);
            format!("data:application/json;base64,{}", base64_encoded_metadata)
        }


        fn construct_image(
            self: @ContractState,
            armour: ByteArray,
            mask: ByteArray,
            background: ByteArray,
            jewelry: ByteArray,
            weapon: ByteArray,
            image_type: RenderType
        ) -> ByteArray {
            // construct svg image

            let image_body: Tag = TagImpl::new("image")
                .attr("href", "data:image/png;base64," + armour)
                .attr("x", "0")
                .attr("y", "0")
                .attr("width", "350px")
                .attr("height", "350px");

            let image_head: Tag = TagImpl::new("image")
                .attr("href", "data:image/png;base64," + mask)
                .attr("x", "0")
                .attr("y", "0")
                .attr("width", "350px")
                .attr("height", "350px");

            let image_background: Tag = TagImpl::new("image")
                .attr("href", "data:image/png;base64," + background)
                .attr("x", "0")
                .attr("y", "0")
                .attr("width", "350px")
                .attr("height", "350px");

            let image_jewelry: Tag = TagImpl::new("image")
                .attr("href", "data:image/png;base64," + jewelry)
                .attr("x", "0")
                .attr("y", "0")
                .attr("width", "350px")
                .attr("height", "350px");

            let image_weapon: Tag = TagImpl::new("image")
                .attr("href", "data:image/png;base64," + weapon)
                .attr("x", "0")
                .attr("y", "0")
                .attr("width", "350px")
                .attr("height", "350px");

            let svg_root: Tag = TagImpl::new("svg")
                .attr("xmlns", "http://www.w3.org/2000/svg")
                .attr("preserveAspectRatio", "xMinYMin meet")
                .attr("viewBox", "0 0 350 350");

            let svg = svg_root
                .insert(image_background)
                .insert(image_head)
                .insert(image_body)
                .insert(image_weapon)
                .insert(image_jewelry)
                .build();

            match image_type {
                RenderType::Svg(()) => { svg },
                RenderType::Base64Encoded(()) => {
                    // @note that will not work unless the node it is being called from
                    // has a high enough max calls step
                    format!("data:image/svg+xml;base64,{}", bytes_base64_encode(svg))
                }
            }
        }


        fn construct_attributes(
            self: @ContractState,
            armour: ByteArray,
            mask: ByteArray,
            background: ByteArray,
            jewelry: ByteArray,
            weapon: ByteArray
        ) -> Span<ByteArray> {
            let armour: ByteArray = JsonImpl::new()
                .add("trait", "Armour")
                .add("value", armour)
                .build();

            let mask: ByteArray = JsonImpl::new().add("trait", "Mask").add("value", mask).build();

            let background: ByteArray = JsonImpl::new()
                .add("trait", "Background")
                .add("value", background)
                .build();

            let jewelry: ByteArray = JsonImpl::new()
                .add("trait", "Jewelry")
                .add("value", jewelry)
                .build();

            let weapon: ByteArray = JsonImpl::new()
                .add("trait", "Weapon")
                .add("value", weapon)
                .build();

            return array![armour, mask, background, jewelry, weapon].span();
        }


        fn get_token_name(self: @ContractState, token_id: u256) -> ByteArray {
            return format!("Blobert #{}", token_id);
        }

        fn get_token_description(self: @ContractState, token_id: u256) -> ByteArray {
            //todo@credence confirm this message

            return format!("Blobert #{} is a member of the BibliothecaDAO", token_id);
        }
    }
}
