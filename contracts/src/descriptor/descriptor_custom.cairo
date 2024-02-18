use blob::types::descriptor::RenderType;
use blob::types::seeder::Seed;

#[starknet::interface]
trait IDescriptorCustom<TContractState> {
    fn custom_count(self: @TContractState) -> u8;
    fn custom(self: @TContractState, index: u8) -> (ByteArray, ByteArray);

    fn token_uri(self: @TContractState, token_id: u256, index: u8) -> ByteArray;
    fn svg_image(self: @TContractState, index: u8) -> ByteArray;
}



#[starknet::contract]
mod DescriptorCustom {

    use blob::descriptor::descriptor_custom::IDescriptorCustom;
    use blob::types::descriptor::{ImageType, RenderType};
    use blob::generation::{custom::image::CUSTOM_IMAGES_COUNT};

    use blob::types::seeder::Seed;
    use blob::utils::encoding::bytes_base64_encode;
    use graffiti::json::JsonImpl;
    use graffiti::{Tag, TagImpl};

    use starknet::ContractAddress;

    use super::ICustomDataDescriptorDispatcher;
    use super::ICustomDataDescriptorDispatcherTrait;


    #[storage]
    struct Storage {
        custom_data_contract_0_19: ContractAddress,
        custom_data_contract_20_39: ContractAddress,
        custom_data_contract_40_49: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, custom_data_contracts: Span<felt252>){
        assert(custom_data_contracts.len() == 3, 'expected 3 data contracts');
        self.custom_data_contract_0_19
            .write((*custom_data_contracts[0]).try_into().unwrap());
        self.custom_data_contract_20_39
            .write((*custom_data_contracts[1]).try_into().unwrap());
        self.custom_data_contract_40_49
            .write((*custom_data_contracts[2]).try_into().unwrap());
    }



    #[abi(embed_v0)]
    impl DescriptorCustomImpl of super::IDescriptorCustom<ContractState> {
        fn custom_count(self: @ContractState) -> u8 {
            CUSTOM_IMAGES_COUNT
        }

        fn custom(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            assert(index < self.custom_count(),'descriptor: index out of range');
            let contract_address = if index < 20 {
                self.custom_data_contract_0_19.read()
            } else if (index < 40) {
                 self.custom_data_contract_20_39.read()
            } else {
                self.custom_data_contract_40_49.read()
            };
            ICustomDataDescriptorDispatcher {contract_address}.custom(index)
        }

        fn token_uri(self: @ContractState, token_id: u256, index: u8) -> ByteArray {
            self.data_uri(token_id, index)
        }

        fn svg_image(self: @ContractState, index: u8) -> ByteArray {
            let (image_bytes, _) = self.custom(index);
            self.construct_image(:image_bytes, image_type: RenderType::Svg)
        }
    }





    #[generate_trait]
    impl InternalImpl of InternalTrait {
     
        fn data_uri(self: @ContractState, token_id: u256, index: u8) -> ByteArray {
            let (image_bytes, _) = self.custom(index);

            let image: ByteArray = self
                .construct_image(:image_bytes, image_type: RenderType::Base64Encoded);

            let attributes: Span<ByteArray> = self.construct_attributes(index);

            let type_: ByteArray = format!("{}", ImageType::CUSTOM);

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

        fn construct_attributes(self: @ContractState, index: u8) -> Span<ByteArray> {
            return array![].span();
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



#[starknet::interface]
trait ICustomDataDescriptor<TContractState> {
    fn custom(self: @TContractState, index: u8) -> (ByteArray, ByteArray);
}

#[starknet::contract]
mod DescriptorCustomData1 {

    use blob::generation::{custom::image::custom_images_0_19};
   
    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl CustomDataDescriptor of super::ICustomDataDescriptor<ContractState> {
        fn custom(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            custom_images_0_19(index)
        }
    }
}

#[starknet::contract]
mod DescriptorCustomData2 {

    use blob::generation::{custom::image::custom_images_20_39};
   
    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl CustomDataDescriptor of super::ICustomDataDescriptor<ContractState> {
        fn custom(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            custom_images_20_39(index)
        }
    }
}

#[starknet::contract]
mod DescriptorCustomData3 {

    use blob::generation::{custom::image::custom_images_40_49};
   
    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl CustomDataDescriptor of super::ICustomDataDescriptor<ContractState> {
        fn custom(self: @ContractState, index: u8) -> (ByteArray, ByteArray) {
            custom_images_40_49(index)
        }
    }
}