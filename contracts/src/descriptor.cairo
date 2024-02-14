use blob::seeder::Seed;
use blob::types::descriptor::ImageType;

#[starknet::interface]
trait IDescriptor<TContractState> {
    fn armour_count(self: @TContractState) -> u32;
    fn armour(self: @TContractState, index: u32) -> (ByteArray, ByteArray);

    fn background_count(self: @TContractState) -> u32;
    fn background(self: @TContractState, index: u32) -> (ByteArray, ByteArray);

    fn jewellry_count(self: @TContractState) -> u32;
    fn jewellry(self: @TContractState, index: u32) -> (ByteArray, ByteArray);

    fn mask_count(self: @TContractState) -> u32;
    fn mask(self: @TContractState, index: u32) -> (ByteArray, ByteArray);

    fn weapon_count(self: @TContractState) -> u32;
    fn weapon(self: @TContractState, index: u32) -> (ByteArray, ByteArray);


    fn token_uri(self: @TContractState, token_id: u256, seed: Seed) -> ByteArray;
    fn token_uri_no_image(self: @TContractState, token_id: u256, seed: Seed) -> ByteArray;
    fn generate_svg_image(self: @TContractState, seed: Seed) -> ByteArray;
}


#[starknet::interface]
trait ITraitsDescriptor<TContractState> {
    fn armour_count(self: @TContractState) -> u32;
    fn armour(self: @TContractState, index: u32) -> (ByteArray, ByteArray);

    fn background_count(self: @TContractState) -> u32;
    fn background(self: @TContractState, index: u32) -> (ByteArray, ByteArray);

    fn jewellry_count(self: @TContractState) -> u32;
    fn jewellry(self: @TContractState, index: u32) -> (ByteArray, ByteArray);

    fn mask_count(self: @TContractState) -> u32;
    fn mask(self: @TContractState, index: u32) -> (ByteArray, ByteArray);


    fn weapon_count(self: @TContractState) -> u32;
    fn weapon(self: @TContractState, index: u32) -> (ByteArray, ByteArray);
}


#[starknet::interface]
trait IMetadataDescriptor<TContractState> {
    fn token_uri(self: @TContractState, token_id: u256, seed: Seed) -> ByteArray;
    fn token_uri_no_image(self: @TContractState, token_id: u256, seed: Seed) -> ByteArray;
    fn generate_svg_image(self: @TContractState, seed: Seed) -> ByteArray;
}


#[starknet::contract]
mod Descriptor {
    use blob::generation::{
        armour::{ARMOUR_COUNT}, mask::{MASK_COUNT}, background::{BACKGROUND_COUNT},
        jewellry::{JEWELLRY_COUNT}, weapon::{WEAPON_COUNT}
    };
    use blob::generation::{
        armour::{armours}, mask::{masks}, background::{backgrounds}, jewellry::{jewellries},
        weapon::{weapons}
    };
    use blob::seeder::Seed;
    use blob::types::descriptor::ImageType;
    use blob::utils::bytes_base64_encode;
    use core::array::ArrayTrait;
    use graffiti::json::JsonImpl;


    use graffiti::{Tag, TagImpl};
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;

    use starknet::ContractAddress;


    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl TraitsMetadata of super::ITraitsDescriptor<ContractState> {
        fn armour_count(self: @ContractState) -> u32 {
            return ARMOUR_COUNT;
        }

        fn armour(self: @ContractState, index: u32) -> (ByteArray, ByteArray) {
            armours(index)
        }

        fn background_count(self: @ContractState) -> u32 {
            return BACKGROUND_COUNT;
        }

        fn background(self: @ContractState, index: u32) -> (ByteArray, ByteArray) {
            backgrounds(index)
        }

        fn jewellry_count(self: @ContractState) -> u32 {
            return JEWELLRY_COUNT;
        }

        fn jewellry(self: @ContractState, index: u32) -> (ByteArray, ByteArray) {
            jewellries(index)
        }

        fn mask_count(self: @ContractState) -> u32 {
            return MASK_COUNT;
        }

        fn mask(self: @ContractState, index: u32) -> (ByteArray, ByteArray) {
            masks(index)
        }

        fn weapon_count(self: @ContractState) -> u32 {
            return WEAPON_COUNT;
        }

        fn weapon(self: @ContractState, index: u32) -> (ByteArray, ByteArray) {
            weapons(index)
        }
    }


    #[abi(embed_v0)]
    impl TokenMetadata of super::IMetadataDescriptor<ContractState> {
        fn token_uri(self: @ContractState, token_id: u256, seed: Seed) -> ByteArray {
            self.data_uri(token_id, seed)
        }

        fn token_uri_no_image(self: @ContractState, token_id: u256, seed: Seed) -> ByteArray {
            self.data_uri_no_img(token_id, seed)
        }

        fn generate_svg_image(self: @ContractState, seed: Seed) -> ByteArray {
            let (armour_bytes, _) = armours(seed.armour);
            let (mask_bytes, _) = masks(seed.mask);
            let (background_bytes, _) = backgrounds(seed.background);
            let (jewellry_bytes, _) = jewellries(seed.jewellry);
            let (weapon_bytes, _) = weapons(seed.weapon);

            self
                .construct_image(
                    armour: armour_bytes,
                    mask: mask_bytes,
                    background: background_bytes,
                    jewellry: jewellry_bytes,
                    weapon: weapon_bytes,
                    image_type: ImageType::Svg
                )
        }
    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn data_uri(self: @ContractState, token_id: u256, seed: Seed) -> ByteArray {
            let (armour_bytes, armour_name) = armours(seed.armour);
            let (mask_bytes, mask_name) = masks(seed.mask);
            let (background_bytes, background_name) = backgrounds(seed.background);
            let (jewellry_bytes, jewellry_name) = jewellries(seed.jewellry);
            let (weapon_bytes, weapon_name) = weapons(seed.weapon);

            let image: ByteArray = self
                .construct_image(
                    armour: armour_bytes,
                    mask: mask_bytes,
                    background: background_bytes,
                    jewellry: jewellry_bytes,
                    weapon: weapon_bytes,
                    image_type: ImageType::Base64Encoded
                );

            let attributes: Span<ByteArray> = self
                .construct_attributes(
                    armour: armour_name,
                    mask: mask_name,
                    background: background_name,
                    jewellry: jewellry_name,
                    weapon: weapon_name
                );

            let metadata: ByteArray = JsonImpl::new()
                .add("name", self._make_token_name(token_id))
                .add("description", self._make_token_description(token_id))
                .add("image", image)
                .add_array("attributes", attributes)
                .build();

            let base64_encoded_metadata: ByteArray = bytes_base64_encode(metadata);
            format!("data:application/json;base64,{}", base64_encoded_metadata)
        }


        fn data_uri_no_img(self: @ContractState, token_id: u256, seed: Seed) -> ByteArray {
            let (_, armour_name) = armours(seed.armour);
            let (_, mask_name) = masks(seed.mask);
            let (_, background_name) = backgrounds(seed.background);
            let (_, jewellry_name) = jewellries(seed.jewellry);
            let (_, weapon_name) = weapons(seed.weapon);

            let attributes: Span<ByteArray> = self
                .construct_attributes(
                    armour: armour_name,
                    mask: mask_name,
                    background: background_name,
                    jewellry: jewellry_name,
                    weapon: weapon_name
                );

            let metadata: ByteArray = JsonImpl::new()
                .add("name", self._make_token_name(token_id))
                .add("description", self._make_token_description(token_id))
                .add("image", "")
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
            jewellry: ByteArray,
            weapon: ByteArray,
            image_type: ImageType
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

            let image_jewellry: Tag = TagImpl::new("image")
                .attr("href", "data:image/png;base64," + jewellry)
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
                .insert(image_jewellry)
                .build();

            match image_type {
                ImageType::Svg(()) => { svg },
                ImageType::Base64Encoded(()) => {
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
            jewellry: ByteArray,
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

            let jewellry: ByteArray = JsonImpl::new()
                .add("trait", "Jewellry")
                .add("value", jewellry)
                .build();

            let weapon: ByteArray = JsonImpl::new()
                .add("trait", "Weapon")
                .add("value", weapon)
                .build();

            return array![armour, mask, background, jewellry, weapon].span();
        }


        fn _make_token_name(self: @ContractState, token_id: u256) -> ByteArray {
            return format!("Blobert #{}", token_id);
        }

        fn _make_token_description(self: @ContractState, token_id: u256) -> ByteArray {
            //todo@credence confirm this message

            return format!("Blobert #{} is a member of the BibliothecaDAO", token_id);
        }
    }
}


#[cfg(test)]
mod tests {
    use snforge_std::{declare, ContractClassTrait};
    use super::ImageType;
    use super::Seed;
    use super::{Descriptor, IDescriptorDispatcher, IDescriptorDispatcherTrait};

    fn delcare__deploy() -> IDescriptorDispatcher {
        let contract = declare('Descriptor');
        let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();
        IDescriptorDispatcher { contract_address }
    }

    fn seed_splat(value: u32) -> Seed {
        Seed { background: value, armour: value, jewellry: value, mask: value, weapon: value }
    }


    #[test]
    fn test_token_uri_no_image() {
        let dispatcher = delcare__deploy();

        let seed = seed_splat(6);
        let metadata = dispatcher.token_uri_no_image(44, seed);

        assert!(
            metadata == "data:application/json;base64,eyJuYW1lIjoiQmxvYmVydCAjNDQiLCJkZXNjcmlwdGlvbiI6IkJsb2JlcnQgIzQ0IGlzIGEgbWVtYmVyIG9mIHRoZSBCaWJsaW90aGVjYURBTyIsImltYWdlIjoiIiwiYXR0cmlidXRlcyI6W3sidHJhaXQiOiJBcm1vdXIiLCJ2YWx1ZSI6IlJvYmUifSx7InRyYWl0IjoiTWFzayIsInZhbHVlIjoiTWlsYWR5In0seyJ0cmFpdCI6IkJhY2tncm91bmQiLCJ2YWx1ZSI6IlB1cnBsZSJ9LHsidHJhaXQiOiJKZXdlbGxyeSIsInZhbHVlIjoiUGxhdGludW0gUmluZyJ9LHsidHJhaXQiOiJXZWFwb24iLCJ2YWx1ZSI6Ikdob3N0IFdhbmQifV19"
        );
    }


    #[test]
    fn test_generate_svg_image() {
        let dispatcher = delcare__deploy();

        let seed = seed_splat(6);
        let image_svg = dispatcher.generate_svg_image(seed);

        assert!(
            image_svg == "<svg xmlns=\"http://www.w3.org/2000/svg\" preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 350 350\"><image href=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAeAAAAHgCAYAAAB91L6VAAAAAXNSR0IArs4c6QAAB5FJREFUeJzt17ENwjAQQFGC6JCYhFGyWVbJOEyCRB1WcIH4CL9XW/Y11tct+7odJwDgq871AAAwIwEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANA4FIPMIvH6zl07n69ffS+UdW7UPqX/zZ6H7/FBgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAIFlX7ejHgIAZmMDBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoCAAANAQIABICDAABAQYAAICDAABAQYAAICDAABAQaAgAADQECAASAgwAAQEGAACAgwAAQEGAACAgwAAQEGgIAAA0BAgAEgIMAAEBBgAAgIMAAEBBgAAgIMAAEBBoDAG83sF8VOMyicAAAAAElFTkSuQmCC\" x=\"0\" y=\"0\" width=\"350px\" height=\"350px\" /><image href=\"data:image/png;base64,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\" x=\"0\" y=\"0\" width=\"350px\" height=\"350px\" /><image href=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAeAAAAHgCAYAAAB91L6VAAAAAXNSR0IArs4c6QAAChhJREFUeJzt3L9vXfUdxvEbkhCUEA/NvUmpkqv+ECE2/TEUFVdBFQMDG17qqANDJ9aKpUsH/wMg1qoDIyJD5W4dWqlDLUylLrSYyEhQ3WTAsdPBUdKIQNK5Kkgfx9/r5/ie12v+6tzjm2O/c5ZnMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC660j6Bng0c8Nx+haa2N2ZpG+BDqg+zy9eOF46d/Pug9K5sycfK537y/X7pXOeZ/ai9vQBAE0JMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABFjC6pjqItDCmaOlcxu3vny4n/t5VN+ee6z0bP1rt7ZYVGWJqFtSz/PK5VOl662s3SmdWzhztPQ8b9z6snQ9zymDgTdgAIgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACLCEdUC6vgjUWnVhqOrnz5woPavPDo+Vrvf6Hz7a1/303Y23f1Y69/u1W6Vzv1m9PSvPc9O/qRazZps3YAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAiwhLVPfVu4OgQiz3TXl7XefGW+dO7ZSydL50bD46VzZ4ePl57nyeZW6XrrG7V3hsWFB02v13rZbWAxi4E3YACIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAg4lr6BrpqVhavqIlBr1YWhKSh9z1XfGx8rLRb9+dc/Kl3vi+Kv3IfX7pbOtV7g+vDa3dL3t7w0avq5XVf9vdzDYlbpex6dOFpbzCr+vaqyrHUwvAEDQIAAA0CAAANAgAADQIAAA0CAAANAgAADQIAAA0CAAANAgCWsferbwlVV9f5aL2a1/tzRk5+X/n3HF8+Vrnd1dbt07vy3TpQWkN58Zb50vdHweOnc9s790rmqyeZW6Vz136P1c596Tq9cOF069+71202X3X586Xzpufr7tZafWte3BS5vwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABDQuyWsueG4dO783BOlczd27+3ndv5P1xeuql7+3X9K51ovhHXd8tKodO7q6nZ1Aam0bLS9c790ver9cTDeeW2xdO7pFy6Xzj336htNl7WqXvrJxdJz+qe/1a43K4tZ3oABIECAASBAgAEgQIABIECAASBAgAEgQIABIECAASBAgAEgoHdLWFU3du+VFmN+9dPvFK94cx930x2phavWC2HV661vVP+PulU6Nb54rni9mm+efbx07rObnzf93Mlm7eetfn9dX4Ar39/adO/j6zz36hulc9W/V8//sPacTmGBq7SYNSu8AQNAgAADQIAAA0CAAANAgAADQIAAA0CAAANAgAADQIAAA0CAJawD8sz3f1A6t/7Pf5TOtV4Oqi5cXblwunjFbi8bdd3y0qh07urqdmlhqHo9DsZT54elc+9/UFscqy/y0SXegAEgQIABIECAASBAgAEgQIABIECAASBAgAEgQIABIECAASDAEtYB+cVv10vn3nltsXSuupi1snandK66cDU/7tfCVXVxbH2j+n/Z2rLR+OK54vXammzW7q/687ZebJsVb733aelc1xeuPv7rWvoWDjVvwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABBgCetrPH3m1JHKubfe+/Rhy8+tLmZVVReu6Jarq9ulc8tLoynfCUnVxazmGn/u89/9Runv6fuf/Lvp53adN2AACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAI6N0S1u7OpHTu48G4esnSwssUNF3gmh8/aHm55tY3av9XXFzI/BzVz63+HK1NNrdK57r+PadM4d8t9XcjorpwVf37PCu8AQNAgAADQIAAA0CAAANAgAADQIAAA0CAAANAgAADQIAAA0BA75awqlKLLHPD8gJXSdcXrvhqy0uj9C3QAX1bhuobb8AAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQYAmLmbK+Ufs/5eLCbCyETTa3Suf69r1UVb8XmAZPHwAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAARYwppxH01q/8eaH/drAam11ktT1YUr4PDyBgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABlrAYDAb9W8xqvVyVMis/R2vV7wWSPKUAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQYAmLPenbYtbbf6z9iszKz5tiuYo+8tQDQIAAA0CAAANAgAADQIAAA0CAAANAgAADQIAAA0CAAANAgCUspqJvi1lV1cWn6vf3y5e/2M/tPDLLVbB/fosAIECAASBAgAEgQIABIECAASBAgAEgQIABIECAASBAgAEgwBIWUdXFp6rqstasLHVZpILDy28vAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABFjC4lB49/rt2sHrjT+49fVa6/r9Fa1cPpW+BThw3oABIECAASBAgAEgQIABIECAASBAgAEgQIABIECAASBAgAEg4Ej6Bvhfc8Nx9ejDad7HYXXlwunSufnxg6afu7J2p3q09e9c6Tm4dPKJxh9bc+3uvcjnHgKl52B3ZzLt+yDIGzAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAEWMLqmD0sYfXNrCx/RZawDgF/i76CJazZ5g0YAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAqzPEGX5i72wDMUs8QYMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADQyH8B43RzB9VSLLgAAAAASUVORK5CYII=\" x=\"0\" y=\"0\" width=\"350px\" height=\"350px\" /><image href=\"data:image/png;base64,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AAEGgAABBoAAAQaAgE76AgAHRXWT00JT25g1OzFR2iB1cWU5sjGLvfECBoAAAQaAAAEGgAABBoAAAQaAAAEGgAABBoAAAQaAAAEGgIDSlhUA2tOdqW3C+tZUbVnhPza2S5uwUqbHO6XWrO9sl86rbhwbdl7AABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAEFBbswLAwFU3XF06c7zV717tHSnNzfc3SnMLvbXqpq6R2s7oBQwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABNmEBDKlz04dKm6FeffduddNU0d1WT5se75R+jvWd7Va/O+y8gAEgQIABIECAASBAgAEgQIABIECAASBAgAEgQIABIECAASCgtJ0EgMHrzsyV5s4/Nl2bm+6WNmbN9zdK5y301kpzTbE1vdWl6nkHghcwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABHTSFwBgd9XNUOdPPr/PN9ndN6ceK224urHx0X5f5UvJCxgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACbMICGFLdmbnS3Ic790pzj48fKc2dP9opbbj6S790XPPXf9U2eo0aL2AACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIKG07AWDwqpuwmqZ5UBm6dOZ46bC7W+OlNvzoytXSeezOCxgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACOukLADBc7n2yU5p78RvPlube+ue1vVznwPICBoAAAQaAAAEGgAABBoAAAQaAAAEGgAABBoAAAQaAAAEGgACbsAD4P79fG3tQmVvb2hyrzHVn5krf7a0uleYOCi9gAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACLAJC4BHcmPjo9LGrKZpShuzRo0XMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAEdNIXAGAwrvaOFCc39vUefMoLGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAJswgIYEd/u3ivNzffH9vkmNI0XMABECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAATYhAUwIq72jhQnN/b1HnzKCxgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAjrpCwAwGPP9jfQV+AwvYAAIEGAACBBgAAgQYAAIEGAACBBgAAgQYAAIEGAACBBgAAiwCQtgRCz01tJX4DO8gAEgQIABIECAASBAgAEgQIABIECAASBAgAEgQIABIECAASDAJiyAL7+x9AX44ryAASBAgAEgQIABIECAASBAgAEgQIABIECAASBAgAEgQIABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWvI/NRpckrut4b8AAAAASUVORK5CYII=\" x=\"0\" y=\"0\" width=\"350px\" height=\"350px\" /><image href=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAeAAAAHgCAYAAAB91L6VAAAAAXNSR0IArs4c6QAABCtJREFUeJzt3LENwjAURdGAEHQpshZbMA8DMAslc1BSuwhV0sAKFol4hJxTW/bvrtz8pgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+C+b9AC/6ni+Vp0bSj/ru2PlfbfLadZ3AfiubXoAAFgjAQaAAAEGgAABBoAAAQaAAAEGgAABBoAAAQaAAAEGgIBdeoClO3Ttq+bc8/6ovdJ2MoAV8AMGgAABBoAAAQaAAAEGgAABBoAAAQaAAAEGgAABBoAAAQaAAJuwJhpKX7W5at+1VfeNpZ80DwDL4AcMAAECDAABAgwAAQIMAAECDAABAgwAAQIMAAECDAABAgwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPCxNyM5EvQaQDRjAAAAAElFTkSuQmCC\" x=\"0\" y=\"0\" width=\"350px\" height=\"350px\" /></svg>",
            "wrong svg image"
        );
    }
// #[test]
// fn test_generate_attributes_with_seed_1() {

//     let dispatcher = delcare__deploy();

//     let seed = seed_splat(1);
//     let attributes 
//         = dispatcher
//             .generate_attributes(seed);

//     assert_eq!(attributes.at(0).clone(), "{\"trait\":\"Armour\",\"value\":\"Demon Armour\"}");
//     assert_eq!(attributes.at(1).clone(), "{\"trait\":\"Mask\",\"value\":\"Doge\"}");
//     assert_eq!(attributes.at(2).clone(), "{\"trait\":\"Background\",\"value\":\"Crypts and Caverns\"}");
//     assert_eq!(attributes.at(3).clone(), "{\"trait\":\"Jewellry\",\"value\":\"Bronze Ring\"}");
//     assert_eq!(attributes.at(4).clone(), "{\"trait\":\"Weapon\",\"value\":\"Banner\"}");
// }

// #[test]
// fn test_generate_attributes_with_seed_3() {

//     let dispatcher = delcare__deploy();

//     let seed = seed_splat(3);
//     let attributes 
//         = dispatcher
//             .generate_attributes(seed);

//     assert_eq!(attributes.at(0).clone(), "{\"trait\":\"Armour\",\"value\":\"Kigurumi\"}");
//     assert_eq!(attributes.at(1).clone(), "{\"trait\":\"Mask\",\"value\":\"Ducks\"}");
//     assert_eq!(attributes.at(2).clone(), "{\"trait\":\"Background\",\"value\":\"Green\"}");
//     assert_eq!(attributes.at(3).clone(), "{\"trait\":\"Jewellry\",\"value\":\"Necklace\"}");
//     assert_eq!(attributes.at(4).clone(), "{\"trait\":\"Weapon\",\"value\":\"Call the Banners\"}");
// }

}

