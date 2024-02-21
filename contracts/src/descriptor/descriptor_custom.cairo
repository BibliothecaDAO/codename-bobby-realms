use blob::types::descriptor::RenderType;
use blob::types::seeder::Seed;

#[starknet::interface]
trait IDescriptorCustom<TContractState> {
    fn custom_count(self: @TContractState) -> u8;
    fn custom(self: @TContractState, index: u8) -> (ByteArray, ByteArray);
    fn token_uri(self: @TContractState, token_id: u256, index: u8) -> ByteArray;
    fn content_uri(self: @TContractState, token_id: u256, index: u8) -> ByteArray;
    fn svg_image(self: @TContractState, index: u8) -> ByteArray;
}


#[starknet::contract]
mod DescriptorCustom {
    use blob::descriptor::descriptor_custom::IDescriptorCustom;
    use blob::generation::{custom::image::CUSTOM_IMAGES_COUNT};
    use blob::generation::{custom::image::custom_images};
    use blob::types::descriptor::{ImageType, RenderType};

    use blob::types::seeder::Seed;
    use blob::utils::encoding::bytes_base64_encode;
    use graffiti::json::JsonImpl;
    use graffiti::{Tag, TagImpl};

    use starknet::ContractAddress;

    #[storage]
    struct Storage {}



    #[abi(embed_v0)]
    impl DescriptorCustomImpl of super::IDescriptorCustom<ContractState> {
        fn custom_count(self: @ContractState) -> u8 {
            CUSTOM_IMAGES_COUNT
        }

        fn custom(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            assert(index < self.custom_count(), 'descriptor: index out of range');
            custom_images(index)
        }

        fn token_uri(self: @ContractState, token_id: u256, index: u8) -> ByteArray {
            self.data_uri(token_id, index, include_image: true)
        }

        fn content_uri(self: @ContractState, token_id: u256, index: u8) -> ByteArray {
            self.data_uri(token_id, index, include_image: false)
        }
        
        

        fn svg_image(self: @ContractState, index: u8) -> ByteArray {
            let (image_bytes, _) = self.custom(index);
            self.construct_image(:image_bytes, image_type: RenderType::Svg)
        }
    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn data_uri(self: @ContractState, token_id: u256, index: u8, include_image: bool) -> ByteArray {
            let (image_bytes, image_name) = self.custom(index);

            let image: ByteArray = self
                .construct_image(:image_bytes, image_type: RenderType::Base64Encoded);

            let attributes: Span<ByteArray> = self.construct_attributes(image_name.clone());

            let type_: ByteArray = format!("{}", ImageType::CUSTOM);

            let metadata = JsonImpl::new()
                .add("name", self.get_token_name(image_name.clone(), token_id))
                .add("description", self.get_token_description(image_name.clone(), token_id))
                .add("type", type_);
            let metadata = if include_image {metadata.add("image", image)} else {metadata};
            let metadata = metadata
                .add_array("attributes", attributes)
                .build();

            let base64_encoded_metadata: ByteArray = bytes_base64_encode(metadata);
            format!("data:application/json;base64,{}", base64_encoded_metadata)
        }


        fn construct_image(
            self: @ContractState, image_bytes: ByteArray, image_type: RenderType
        ) -> ByteArray {
            // construct svg image

            let image: Tag = TagImpl::new("image")
                .attr("href", "data:image/png;base64," + image_bytes)
                .attr("x", "0")
                .attr("y", "0")
                .attr("width", "350px")
                .attr("height", "350px");

            let svg_root: Tag = TagImpl::new("svg")
                .attr("xmlns", "http://www.w3.org/2000/svg")
                .attr("preserveAspectRatio", "xMinYMin meet")
                .attr("style", "image-rendering: pixelated")
                .attr("viewBox", "0 0 350 350");

            let svg = svg_root.insert(image).build();

            match image_type {
                RenderType::Svg(()) => { svg },
                RenderType::Base64Encoded(()) => {
                    // @note that will not work unless the node it is being called from
                    // has a high enough max calls step
                    format!("data:image/svg+xml;base64,{}", bytes_base64_encode(svg))
                }
            }
        }

        fn construct_attributes(self: @ContractState, name: ByteArray) -> Span<ByteArray> {
            let name: ByteArray = JsonImpl::new().add("name", name).build();

            return array![name].span();
        }


        fn get_token_name(self: @ContractState, name: ByteArray, token_id: u256) -> ByteArray {
            return format!("{} #{}", name,  token_id);
        }

        fn get_token_description(self: @ContractState, name: ByteArray, token_id: u256) -> ByteArray {
            return format!("{} #{} is a squire from Realms World", name, token_id);
        }
    }
}
