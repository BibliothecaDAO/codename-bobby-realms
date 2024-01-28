use core::option::OptionTrait;
use core::byte_array::ByteArrayTrait;
use core::clone::Clone;
use graffiti::{Tag, TagImpl};
use graffiti::json::{JsonImpl};
use blob::seeder::Seed;
use alexandria_encoding::base64::Base64Encoder;

use blob::generation::{
    armour::{armours}, mask::{masks}, background::{backgrounds},
    jewellry::{jewellries}, weapon::{weapons}
};



/// Generate blobert metadata given the token id and seed
///
/// # Arguments
/// * `token_id` - the token id of blobert
/// * `seed` - the seed needed to generate blobert
///
/// # Returns
/// * `ByteArray` - a uri containing the base64 encoded json metadata of blobert
///                 e.g. "data:application/json;base64,eyJ0cmFpdCI6IC.."
///
fn blobert(token_id: u256, seed: Seed) -> ByteArray {

    let (armour_bytes, armour_name) = armours(seed.armour);
    let (mask_bytes, mask_name) = masks(seed.mask);
    let (background_bytes, background_name) = backgrounds(seed.background);
    let (jewellry_bytes, jewellry_name) = jewellries(seed.jewellry);
    let (weapon_bytes, weapon_name) = weapons(seed.weapon);

    let image: ByteArray = construct_base64_image(
        armour: armour_bytes, 
        mask: mask_bytes, 
        background: background_bytes, 
        jewellry: jewellry_bytes, 
        weapon: weapon_bytes
    );

    let attributes: Span<ByteArray> = construct_json_attributes(
        armour: armour_name, 
        mask: mask_name, 
        background: background_name, 
        jewellry: jewellry_name, 
        weapon: weapon_name
    ); 


    let metadata: ByteArray = JsonImpl::new()
        .add("name", make_name(token_id))
        .add("description", make_description(token_id))
        .add("image", image)
        .add_array("attributes", attributes)
        .build();

    let base64_encoded_metadata: ByteArray = bytes_base64_encode(metadata);
    return format!(
        "data:application/json;base64,{base64_encoded_metadata}"
    );

}


/// Construct the base64 encoded svg image of blobert
/// given the png bytes of the armour, mask, background, jewellry and weapon
///
/// # Arguments
/// * `armour` - the png bytes of the armour
/// * `mask` - the png bytes of the mask
/// * `background` - the png bytes of the background
/// * `jewellry` - the png bytes of the jewellry
/// * `weapon` - the png bytes of the weapon
///
/// # Returns
/// * `ByteArray` - the base64 encoded svg image 
///                 e.g "data:image/svg+xml;base64,PHN2ZyB4..."
///
fn construct_base64_image(
        armour: ByteArray, mask: ByteArray, 
        background: ByteArray, jewellry: ByteArray, weapon: ByteArray
    ) -> ByteArray {
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


    // construct the svg image
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

    format!("data:image/svg+xml;base64,{}", bytes_base64_encode(svg))
        
}




/// Construct the json attributes of blobert
/// given the name of the armour, mask, background, jewellry and weapon
///
/// # Arguments
/// * `armour` - the name of the armour
/// * `mask` - the name of the mask
/// * `background` - the name of the background
/// * `jewellry` - the name of the jewellry
/// * `weapon` - the name of the weapon
///
/// # Returns
/// * `Span<ByteArray>` - the json attributes of blobert
///                       e.g. array![
///                             "{\"trait\": \"Armour\", \"value\": \"Armour 1\"}",
///                             "{\"trait\": \"Mask\", \"value\": \"Mask 1\"}",
///                             "{\"trait\": \"Background\", \"value\":\"Background1\"}",
///                             "{\"trait\": \"Jewellry\", \"value\": \"Jewellry 1\"}", 
///                             "{\"trait\": \"Weapon\", \"value\": \"Weapon 1\"}"
///                           ].span();
///
fn construct_json_attributes(
        armour: ByteArray, mask: ByteArray, 
        background: ByteArray, jewellry: ByteArray, weapon: ByteArray
    ) -> Span<ByteArray> {

        let armour : ByteArray = JsonImpl::new()
            .add("trait", "Armour")
            .add("value", armour)
            .build();

        let mask : ByteArray = JsonImpl::new()
            .add("trait", "Mask")
            .add("value", mask)
            .build();

        let background : ByteArray = JsonImpl::new()
            .add("trait", "Background")
            .add("value", background)
            .build();

        let jewellry : ByteArray = JsonImpl::new()
                .add("trait", "Jewellry")
                .add("value", jewellry)
                .build();

        let weapon : ByteArray = JsonImpl::new()
            .add("trait", "Weapon")
            .add("value", weapon)
            .build();

        return array![
            armour, mask, background, jewellry, weapon
        ].span();
}




/// Convert bytes array to base64 encoded bytes array
/// (Basically base64 encoding a string)
///
/// # Arguments
/// * `bytes` - the bytes array to be encoded
///
/// # Returns
/// * `ByteArray` - the base64 encoded bytes array
///                 e.g. "aGVsbG8gd29ybGQ="
///
fn bytes_base64_encode(_bytes: ByteArray) -> ByteArray {

    // convert bytes array to Array<u8>
    let mut bytes_u8: Array<u8> = array![];
    let mut count = 0;
    loop {
        if count == _bytes.len() {
            break;
        }

        bytes_u8
            .append(_bytes.at(count).unwrap());
        count += 1;
    };

    /// base64 encode Array<u8>
    let encoded_bytes_u8 = Base64Encoder::encode(bytes_u8);

    // convert Array<u8> to ByteArray
    let mut count = 0;
    let mut encoded_bytes: ByteArray = "";
    loop {
        if count == encoded_bytes_u8.len() {
            break;
        }
        encoded_bytes
            .append_byte(*encoded_bytes_u8[count]);
        count += 1;
    };

    return encoded_bytes;
}

fn make_name(token_id: u256) -> ByteArray {
    return format!("Blobert #{}", token_id);
}

fn make_description(token_id: u256) -> ByteArray {
    return format!("Blobert #{} is a member of the BibliothecaDAO", token_id);
}

#[cfg(test)]
mod tests {
    mod test_blobert {
        use super::super::{blobert, Seed};

        #[test]
        #[available_gas(100000000000000000)]
        fn test_blobert() {
            let token_id: u256 = 1;
            let seed: Seed = Seed {
                armour: 2,
                mask: 1,
                background: 2,
                jewellry: 3,
                weapon: 1
            };

            let blobert_metadata: ByteArray = blobert(token_id, seed);
            // // println!("blobert_metadata: {}", blobert_metadata);
            // assert!(
            //     blobert_metadata == "",
            //     "wrong blobert metadata"
            // );
        }
    }



    mod test_bytes_encoder {
        use super::super::{bytes_base64_encode};

        #[test]
        fn test_bytes_base64_encode() {
            // test "hello world"
            let bytes: ByteArray = "hello world";
            let encoded_bytes: ByteArray = bytes_base64_encode(bytes);

            assert!(encoded_bytes == "aGVsbG8gd29ybGQ=", " encoded bytes are not equal");

            // test "hi blobert, how are you doing today? I hope you are doing well"
            let bytes: ByteArray = "hi blobert, how are you doing today? I hope you are doing well";
            let encoded_bytes: ByteArray = bytes_base64_encode(bytes);
            assert!(
                encoded_bytes == "aGkgYmxvYmVydCwgaG93IGFyZSB5b3UgZG9pbmcgdG9kYXk/IEkgaG9wZSB5b3UgYXJlIGRvaW5nIHdlbGw=", 
                "encoded bytes are not equal"
            );
        }

        // 4,385,075,082
    }

    

    mod test_construct_base64_image {
        use super::super::{construct_base64_image};
        use blob::generation::{
            armour::{armours}, mask::{masks}, background::{backgrounds},
            jewellry::{jewellries}, weapon::{weapons}
        };

        #[test]
        fn test_construct_base64_image() {
            let (armour_bytes, _) = armours(2);
            let (mask_bytes, _) = masks(1);
            let (background_bytes, _) = backgrounds(2);
            let (jewellry_bytes, _) = jewellries(3);
            let (weapon_bytes, _) = weapons(1);

            let image_bytes: ByteArray = construct_base64_image(
                armour: armour_bytes, 
                mask: mask_bytes, 
                background: background_bytes, 
                jewellry: jewellry_bytes, 
                weapon: weapon_bytes
            );

            assert!(image_bytes == "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaW5ZTWluIG1lZXQiIHZpZXdCb3g9IjAgMCAzNTAgMzUwIj48aW1hZ2UgaHJlZj0iZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFlQUFBQUhnQ0FZQUFBQjkxTDZWQUFBQUFYTlNSMElBcnM0YzZRQUFEZnRKUkVGVWVKenQzTityMy9kQngvRWNQYXlJbEdZa2k0S2d4a09sYWk1R0tLV0pFQ1hRZzJLdzlXSjEwTndvRExPV0NRMHRTdmZqWXFOVnFiVGdhTldiWEVoN3NWNUlMeEswS1F6cFNGUEtzRGR4Rm1WT3ZOTFlJYjNZeFVRNS9nUEh3enM1NzNPZTN4K1B4L1dIOS9lOTdXUlAzamV2alNOSGp1d2NXUUVuUG4ycXZzS2VIbmo0OHRUekh0KzROZlU4bHRNYk8yTi85eCsrOTlJQjMrUndmT1hNZHZLN2ovendadks3czcxOXo1bWg3MGIvODQ2ZXgrNStwTDRBQUt3akFRYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FnYzF6bDY0TWZmak9YL3p1QVYrRkkwY3NYSEZuUnY5ZXZuckE5emdzWDcxNVBmbmRSMDdmbS96dXFHcmh5bUxXL25nQkEwQkFnQUVnSU1BQUVCQmdBQWdJTUFBRUJCZ0FBZ0lNQUFFQkJvQ0FBQU5BWU9QY3BTczdNdytzRnJOT2ZQcFU4cnVqdm5KbXU3NENLK2owMFd2Sjc3NzBsMVAvYjJQdC9PcHZYNml2Y0todW43cS92c0pDOGdJR2dJQUFBMEJBZ0FFZ0lNQUFFQkJnQUFnSU1BQUVCQmdBQWdJTUFBRUJCb0RBNXV3RHoxMjZNdlJkdFpnMTJ3TVBYeDc4OHRhQjNtTlpQZmJRdDRlK2UvUDlCdy80SnR5Snk3KzNNZlc4ZFZ2VytydHZYSjE2M3JvdGE2MEtMMkFBQ0Fnd0FBUUVHQUFDQWd3QUFRRUdnSUFBQTBCQWdBRWdJTUFBRUJCZ0FBaE1YOElhdGVpTFdlTUxWK3htZE9HSzNaMCtlcTIrd3FFYVhkWTZmdTdKb2UrZWUrS1YvVnhuNlZqV1drNWV3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnSU1BQUVOZzRkK25LVG4ySkdUNTg3NldoNzZxRnE4YzNiaVcvTzF1MWNQWG0rdzhtdjF0WnR5V3MwWVdyeXJvdGE4MzJpMTk3dXI3Q1F2SUNCb0NBQUFOQVFJQUJJQ0RBQUJBUVlBQUlDREFBQkFRWUFBSUNEQUFCQVFhQXdHWjlnVm0rZGZyZW9lOCtkOEQzV0ZiVnd0VzZzWEMxbkY1NC9hbXA1NjNic3RaM3Z2enkxUE5XWlZuTEN4Z0FBZ0lNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkFRWUFBSUNEQUFCQVFZQUFJYjV5NWQyYWt2c1pjL2V2djVvZStPLzhxSnFiLzd1VS9NM2N4NmZPUFcxUE5HcmNyQzFadnZQMWhmWVlwVldjSmFsWVdyVmJGdXkxcXpWY3RhWHNBQUVCQmdBQWdJTUFBRUJCZ0FBZ0lNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkRJbHJCR0Y2NUd6VjdDR2pXNm1EVjdDV3RWRnE1R0xmb1Nsb1VyVm9sbHJmMFpYZGJ5QWdhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBUUVHQUFDQWd3QUFRRUdnTUQwSmF6WkMxZWpxaVdzVVcvZmMyYm91M1ZidUJwbENXdC9MRnhSc3F5MU95OWdBQWdJTUFBRUJCZ0FBZ0lNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkFRWUFBSWJJNStXQzFjalpxOU5EVzZ2RFI2M21OSExGd3RvMFZmdUlKbDhNTHJUdzE5OTlxL2ZHTG91Kzk4K2VYOVhHZGhlQUVEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQmdjOUVYcmtaVkMxZXp6NE4xOVBRLy9NTFFkeS8vMGo4ZThFMDRDS01MVnhkLzdyL0h6dnZhMDFQUGUrNkpWNGErbTgwTEdBQUNBZ3dBQVFFR2dJQUFBMEJBZ0FFZ0lNQUFFQkJnQUFnSU1BQUVCQmdBQXB2MUJXYXhjTVdkT0gzMFduMEY3b0xGck9VMHZIQTFlekZyOEx3WFhuOXE2THRSbzh0YVhzQUFFQkJnQUFnSU1BQUVCQmdBQWdJTUFBRUJCb0NBQUFOQVFJQUJJQ0RBQUJCWW1TV3NhdUhLWWhZc0hvdFppNlZhdUJvOWI3YlJaUzB2WUFBSUNEQUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDR3pjMk5yYXFTOHh3d2ZiajlaWDJKTWxyUDBaWFJ3N2ZmVGFBZDlrZjNiZStKLzZDbnZhZUx3WngzdisyTmVUM3gwMXVwZzFlNEZyOUR5V2t4Y3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnSU1BQUVCQmdBQWdJTUFBRW10a2JXRk9qUzFQVll0Ym83MWFMV1pWcTRjcGkxbkw2NHZlL01QU2RGekFBQkFRWUFBSUNEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBVFdhODZHcFhYNjZMWDZDb2ZLWXRaaXNYQzEya2FYcTJiekFnYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ01CcXpOVEFtbHFWeGF3am56L1llK3hYdFhCbE1XdDMxWExWYkY3QUFCQVFZQUFJQ0RBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQWd3QUFRV0prbHJOdW43cSt2c0tjZmZPdG1mWVhsOWhQMUJaYmI2R0xXODhlK2ZzQTNXVTdQL2ZuWVZOZC9qcDQzK04zczh5by84NldmbW5yZVBiOXpZK3A1bnpwMmZPcDVvN3lBQVNBZ3dBQVFFR0FBQ0Fnd0FBUUVHQUFDQWd3QUFRRUdnSUFBQTBCQWdBRWdzREpMV0t5Mm4vNzVzU21zZi91bi96amdtNnkyTDM3L0MwUGZXY3hhYmI5MTc0OU5QZS92QjcrNzV6Zi9ldXJ2TGpvdllBQUlDREFBQkFRWUFBSUNEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0ZqQ1lxVll6RG9jRnJNV3kremxxdG5XYmVGcWxCY3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnSU1BQUVCQmdBQWdJTUFBRUxHR3hsaXhtSFE2TFdidjdZUHZSdVFmZXZENzNQQTZGRnpBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFzWWNFZUxHWWRqa1ZmekpxK1hMVm1QblhzZUgyRmhlUUZEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBUUVHQUFDQWd3QUFVdFlNSUhGck1PeDZJdFpveDU3Nk50VHozdGo1L0xRZHgrKzk5TFUzMlYvdklBQklDREFBQkFRWUFBSUNEQUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0JnQ1FzT2tjV3N3ekY3TVd2MmNsWGxnWWN0WmgyR0cxdGJROTk1QVFOQVFJQUJJQ0RBQUJBUVlBQUlDREFBQkFRWUFBSUNEQUFCQVFhQWdBQURRTUFTRml3Z2kxbUhZM1F4NjhpeHNmODlWb1hGck4yTkxseU44Z0lHZ0lBQUEwQkFnQUVnSU1BQUVCQmdBQWdJTUFBRUJCZ0FBZ0lNQUFFQkJvREF4bzJ0clozNkVqTzhkZm1aK2dwN09ubCt1NzdDbnM2K2VMRyt3cDQyUHZQWitncEw3YU4zWHEydk1NVWYvdGNmSkwvN3g1LzhrK1IzSzhmUFBUbjF2RVgvKzZ2K3JyeUFBU0Fnd0FBUUVHQUFDQWd3QUFRRUdBQUNBZ3dBQVFFR2dJQUFBMEJBZ0FFZ3NGbGZBR0RVNkNKVnRXekVjcXIrcnJ5QUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnc0hGamEydW52c1FNYjExK3ByN0NuazZlMzY2dk1NWFpGeThtdjd2eG1jOG12OHZoK09pZFY1UGZIVjAyR2wxS1luZkh6ejA1OWJ6cTcyWFU2TitWRnpBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVEyNndzQVZDeGNjUkJHLzY2OGdBRWdJTUFBRUJCZ0FBZ0lNQUFFQkJnQUFnSU1BQUVCQm9DQUFBTkFRSUFCSUdBSml6dnk3ck92RFgxMzlzV0xCM3dUN3NSSDc3eWEvTzd4YzA5Ty9hNXk0MmN2VEQzdkIzLzJ5dFR6RnQzcDZPOXYwWGtCQTBCQWdBRWdJTUFBRUJCZ0FBZ0lNQUFFQkJnQUFnSU1BQUVCQm9DQUFBTkF3QkxXaXZ2ZU42OFBmWGZ5L1BZQjM0UlZzdWpMVll2dXgzLy9xYW5ucmR1eTFxSWIvZmZoQlF3QUFRRUdnSUFBQTBCQWdBRWdJTUFBRUJCZ0FBZ0lNQUFFQkJnQUFnSU1BQUZMV0V0cWRPR3E4dTZ6cncxOWQvYkZpd2Q4RSs2RWhhdmxaRm5yY016KzkrRUZEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBUUVHQUFDQWd3QUFVdFlDMmJSRjY1WVRoYXV1Qk96bDdXTy9OVzF1ZWROVnYzNzhBSUdnSUFBQTBCQWdBRWdJTUFBRUJCZ0FBZ0lNQUFFQkJnQUFnSU1BQUVCQm9EQXhvMnRyWjM2RW50NTYvSXo5UlhXd3NuejIvVVZsdHFGRS9jTmZYZjE5c2NMZlI2Nys5OS9mN2Urd3A1KzlDZlAxbGZZMHplKzlFTHl1OU1YdlNiekFnYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ01CbTljTVdybGdsbzR0VTFYbXN0dGxMWFl1K3JMWG9DMWVqdklBQklDREFBQkFRWUFBSUNEQUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0F3ZlFuTHdoWHI2TUtKKzRhK0cxMjRtbjBlM0luWnkxcWpWbVhoYXBRWE1BQUVCQmdBQWdJTUFBRUJCb0NBQUFOQVFJQUJJQ0RBQUJBUVlBQUlDREFBQklhWHNDeGN3Zjl2OWlLVmhTdFd5Ym90WEkzeUFnYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ01EbUI5dVAxbmZnTHB3OHYxMWZBWUI5OEFJR2dJQUFBMEJBZ0FFZ0lNQUFFQkJnQUFnSU1BQUVCQmdBQWdJTUFBRUJCb0RBNXVpSEoyNzk4OUIzdDAvZGY5ZVhBWUIxNFFVTUFBRUJCb0NBQUFOQVFJQUJJQ0RBQUJBUVlBQUlDREFBQkFRWUFBSUNEQUNCNFNXc1VSYXpkbmZ5L1BiVTg3NzN6ZXRUejV0OVB3RDI1Z1VNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkFRWUFBSUNEQUFCQVFZQUFJQ0RBQ0I2VXRZb3l4bUFiRE92SUFCSUNEQUFCQVFZQUFJQ0RBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQ3c4UnQvZW4ybnZzUU12LzdkdjYydnNCWWUrZUhOK2dyY2hYZWZmYTIrd2xMNzVYKzlXbDloVDU5ODZJbjZDdHdGTDJBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnSU1BQUVCQmdBQWhzMWhlWTVXKzJmbTNvTzR0WisvUDJQV2VHdnJPWUJZdm42dTJQaDc2N2NPSytsVGh2MFhrQkEwQkFnQUVnSU1BQUVCQmdBQWdJTUFBRUJCZ0FBZ0lNQUFFQkJvQ0FBQU5BWUdXV3NFWlp6RG9jRnJOZzhjeGVrRnIwOHhhZEZ6QUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDQWd3QUFUV2JnbHJsTVdzdzJFeEN3N1AxZHNmRDMwM3VrZzErN3gxNHdVTUFBRUJCb0NBQUFOQVFJQUJJQ0RBQUJBUVlBQUlDREFBQkFRWUFBSUNEQUFCUzFqN1pESHJjSXd1WmxVc2RiRU1aaTlTV2JqYTNlaENtQmN3QUFRRUdBQUNBZ3dBQVFFR2dJQUFBMEJBZ0FFZ0lNQUFFQkJnQUFnSU1BQUVMR0VCckluUmhhWjFXN2dhL2U5bE5pOWdBQWdJTUFBRUJCZ0FBZ0lNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkFRWUFBSS9CLzlRQnJzRktxSDFRQUFBQUJKUlU1RXJrSmdnZz09IiB4PSIwIiB5PSIwIiB3aWR0aD0iMzUwcHgiIGhlaWdodD0iMzUwcHgiIC8+PGltYWdlIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBZUFBQUFIZ0NBWUFBQUI5MUw2VkFBQUFBWE5TUjBJQXJzNGM2UUFBQ1psSlJFRlVlSnp0M0Q5bzNHVWN4L0ZmTkxhbTRKVktVR3N3aUZaVHFEZ0VnNG9WRkFjUm9WdEZoMHB4Y1l1RG82NU80dExOTGREQllnZWgwckhnNEY4aTNZUUdSU1FTdXdTTEp6UmFLM0gzSDkvMG51dm5MdmQ2elErL2U5SXI5K2EzZkxvT0FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQ2dsYW4wQmRpZGVyUHo2U3Y4ci83bWV2b0tZODMzQzRPN0pYMEJBSmhFQWd3QUFRSU1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBZ3dBQVFJTUFBSFQ2UXN3WHFvTFNFdDMzRlk2dC9yckg5dUQzT2Z2bnJ0M3ByVHVkcUdyL1IyVHRxaFUvWDZmdTNlbWRPN0NUMXUrWC9nUDNvQUJJRUNBQVNCQWdBRWdRSUFCSUVDQUFTQkFnQUVnUUlBQklFQ0FBU0JBZ0FFZ3dCSVdRMUZkdUZwWk9GQjYzcEdGZmFWelMrYzJTcC9iZWxGcHQyaTljTFY2Ykc2ZysveGQ5ZnZ0dXE3MC9VS1NOMkFBQ0JCZ0FBZ1FZQUFJRUdBQUNCQmdBQWdRWUFBSUVHQUFDQkJnQUFnUVlBQUlzSVRGV0RpOVdqdFhYVjZxTGlyZHYvZlcwcUxTRDcvL1dWMW9pamk4LzdiYThsZmpoYXZxOTdiWXUxbzdDTHVJTjJBQUNCQmdBQWdRWUFBSUVHQUFDQkJnQUFnUVlBQUlFR0FBQ0JCZ0FBZ1FZQUFJc0lURnJsSmRYcXFxTGx5dExCd29QZS9Jd3I2QjduT2pxc3RmVmEzL25XRVNlUU1HZ0FBQkJvQUFBUWFBQUFFR2dBQUJCb0FBQVFhQUFBRUdnQUFCQm9BQUFRYUFBRXRZN0NxbkxtK1V6bFdYcTZwU0MxZFZxOGZtU3VlK1didGFPbmR5cmZidnZIeXc5cmt3aWJ3QkEwQ0FBQU5BZ0FBRFFJQUFBMENBQUFOQWdBQURRSUFBQTBDQUFBTkFnQUFEUUlBbExLSXU5bXNMVXRXRnEvcnlVbTN4YWRRWHJscXIvcjByeGVlVkY3TzY2dmQycFhnT1JwODNZQUFJRUdBQUNCQmdBQWdRWUFBSUVHQUFDQkJnQUFnUVlBQUlFR0FBQ0JCZ0FBaVlTbCtBMGRDYm5XLzl5TzJXRDZzdVhDMzJNZ3RYVThkZmJ2cTg3Yk5ubWo2dkt2VjNMSjJyTFdidFFPbTNyYis1M3Zwem9jd2JNQUFFQ0RBQUJBZ3dBQVFJTUFBRUNEQUFCQWd3QUFRSU1BQUVDREFBQkFnd0FBUk1weThBbzZ6MU1sVFY2ZFhhdVJOTGJaLzM2dkhhdWFycXY5OXFGMXZNZ2hodndBQVFJTUFBRUNEQUFCQWd3QUFRSU1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBd2xiNEFvNkUzTzkvNmtkdVZROHNINTVwK2FIVVo2cHUxcTZWekYvdjdCcmpOamF2K0hhMVZGN05hVyt6VnZvK1RhMWRLNXc3UFRKZCsyeTV0WFM4OXI3KzVYam9ITytFTkdBQUNCQmdBQWdRWUFBSUVHQUFDQkJnQUFnUVlBQUlFR0FBQ0JCZ0FBZ1FZQUFLbTB4ZGd2TXp0MlZNNnQzSHQycEJ2TXBnakM3V0ZxNmZmL2JoMDdzR0Z4VUd1OHc4bnVyWUxZVlZ2ZkpMNWUxZVhhbi92U3ZGNUo5ZXVsSmJZT211QUJIa0RCb0FBQVFhQUFBRUdnQUFCQm9BQUFRYUFBQUVHZ0FBQkJvQUFBUWFBQUFFR2dBQkxXT3pJeHJWcnBZV2g1WU8xWmFNbmo5MDMwSDMrNGZLUGJaL0hTSG5rN2RkcUIwKzhOOXlMUUFQZWdBRWdRSUFCSUVDQUFTQkFnQUVnUUlBQklFQ0FBU0JBZ0FFZ1FJQUJJRUNBQVNCZ0tuMEJSa052ZHI1NnRMU0U5Y0hyVDl6NFpRYncwTkdubWo1disreVpwcy9qMzAwZGY3bnA4eDZyTDJHVmZnUDdtK3MzZmhuNEQ5NkFBU0JBZ0FFZ1FJQUJJRUNBQVNCQWdBRWdRSUFCSUVDQUFTQkFnQUVnUUlBQklHQTZmUUdHcTdwd2RYaW05bC9oMHRiMVFhNHpkbG92TkZYdFlNbXBxYTlQdnhuNVhKaEUzb0FCSUVDQUFTQkFnQUVnUUlBQklFQ0FBU0JBZ0FFZ1FJQUJJRUNBQVNCQWdBRWd3QklXWGRkMTNhV3Q2OXVWY3lzTEI0WjlsYkZVWGE2cUxrMVZ6N1grM0tyVTU4SnU0ZzBZQUFJRUdBQUNCQmdBQWdRWUFBSUVHQUFDQkJnQUFnUVlBQUlFR0FBQ0JCZ0FBaXhoTVJTL2Y3SldPcmYzbVlVaDMrVG1hTDFjMVZycno3VndCWVB6Qmd3QUFRSU1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBZ3dBQVFJTUFBRUNEQUFCbHJEWWtZdjlmYVZ6aTcycnBYTVdzOWlKYnovOUxIMEZhTVliTUFBRUNEQUFCQWd3QUFRSU1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBZ3dBQVJZd3FMcnVxNDdkUHZNVk9YY3Fjc2IyNVZ6eTkxYzZYTmJMMlo5V3pyVmRROGRmYXA0a3B1aHVuRDF5dnRmbHM0OS9zQ2RwZi9QWDMzL2MrbDVNQXplZ0FFZ1FJQUJJRUNBQVNCQWdBRWdRSUFCSUVDQUFTQkFnQUVnUUlBQklFQ0FBU0NndEJiRDd0ZWJuUytkTzNUN1RPbmNkNzl0bFJhenFwWVAxcGExcW02NWYwL3AzT09QM3QzMGM2dEdmYW1ydWx4VmxWcTQ2bSt1bDg3Qk1IZ0RCb0FBQVFhQUFBRUdnQUFCQm9BQUFRYUFBQUVHZ0FBQkJvQUFBUWFBQUFFR2dBQkxXT3hJZFRHcnFycXNkWFQrenRLNTU1KzlyK2tDMTZndlV1MFdINTMvdlBSYjlNNlpMMHJQczNERk9QQUdEQUFCQWd3QUFRSU1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBZ3dBQVFJTUFBR1dzQmdMNTk5NnFlbnpadmIzU3VlMmZ1azNYZFpxYlF5V3Vwcit4ano4d2hzdEh3ZFIzb0FCSUVDQUFTQkFnQUVnUUlBQklFQ0FBU0JBZ0FFZ1FJQUJJRUNBQVNCQWdBRWd3QklXRTZuMXN0WVFSQmE0N2pyMFlPazNZZjg5OXpUOVhBdFhUQ0p2d0FBUUlNQUFFQ0RBQUJBZ3dBQVFJTUFBRUNEQUFCQWd3QUFRSU1BQUVDREFBQkJnQ1F0dW9pRXNjTFZlekNyOUpyejR6b2VOUHhZbWp6ZGdBQWdRWUFBSUVHQUFDQkJnQUFnUVlBQUlFR0FBQ0JCZ0FBZ1FZQUFJRUdBQUNKaE9Yd0FtU1hWQmFnaUxXVmJ2WU1SNEF3YUFBQUVHZ0FBQkJvQUFBUWFBQUFFR2dBQUJCb0FBQVFhQUFBRUdnQUFCQm9BQVMxZ3czcG91WEZXWHVvREJlUU1HZ0FBQkJvQUFBUWFBQUFFR2dBQUJCb0FBQVFhQUFBRUdnQUFCQm9BQUFRWUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBSUF4OHhlbXlBcUtGL3NZc2dBQUFBQkpSVTVFcmtKZ2dnPT0iIHg9IjAiIHk9IjAiIHdpZHRoPSIzNTBweCIgaGVpZ2h0PSIzNTBweCIgLz48aW1hZ2UgaHJlZj0iZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvQUFBQU5TVWhFVWdBQUFlQUFBQUhnQ0FZQUFBQjkxTDZWQUFBQUFYTlNSMElBcnM0YzZRQUFERkJKUkVGVWVKenQzRitzMTNVZEJ2QWZ5QkE3Y3NUa3FCVmhwQ0pEMUkwOC9ra1JjSzNKR05aRjAzV2hocU41SWN6bWFtNXREVnhkNUthdVRXNWNiVUFYT1p0Y05iTzE1cEdvUE1weUtlaEVYU2doT1QwbUhTV0psblRSbFV2YkErZHp6dnQzZnVmMXVuNzIrWDQ0NTh0NTlyMTVPaDBBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFDZ2UwMnJ2Z0FucG4vdS9Pb3JOREU2c3IvNkNuU0I5SDIrOHN4TG90emIvendVNWM0NGVVNlVlL0xOWjZPYzk1bmpNYjM2QWdBd0ZTbGdBQ2lnZ0FHZ2dBSUdnQUlLR0FBS0tHQUFLS0NBQWFDQUFnYUFBZ29ZQUFyTXFMNEFINVl1QWkwODdad285OUxmWHpzMmx2dWNxSGw5WjBVcmEvMW5uQlNkZDkwbGZWSHV5Z1VuUjdrTEYyWG56VnY3MnlqSFIydjlQai81NXJQUiszem5SYmRFNTkyL2UxdVVXM2phT2RINy9GSjBtc1VzL3NzWE1BQVVVTUFBVUVBQkEwQUJCUXdBQlJRd0FCUlF3QUJRUUFFRFFBRUZEQUFGRkRBQUZJaldYUmk3cW9XcmRCR290WFJoS0xYcHFteTU2b2F2RGtTNVArMjlNSHIzcDg4Nk5UcnY2UjJ6b3R5bW9lOUh1VzUzWU1zMVVlNW52end0eXYxZ3FPM0NWV3ZIOFQ0My9adHFNYXUzK1FJR2dBSUtHQUFLS0dBQUtLQ0FBYUNBQWdhQUFnb1lBQW9vWUFBb29JQUJvSUFDQm9BQ2xyREdhS290WFBXS0RSc1BSYmtIN3A0VDVjNWJmRFQ2di9US0N6T2o4MW92Wm0xYStiMG9kOW55STFIdWxIKzlIK1hPUCsrNTZIMGUzcjRtT20vUDRkRW90NlN2ditsNXJaZmRPaGF6NlBnQ0JvQVNDaGdBQ2loZ0FDaWdnQUdnZ0FJR2dBSUtHQUFLS0dBQUtLQ0FBYUNBQWdhQUFwYXdQa2E2Y0xWc3dVbFJidWUrZjVjc1hLV0xRSzJsQzBQZHJsY1dzOUlsckU2bkU3Mm42YzlsNk43cy8xR3FhZ2tyMVhveDYrSlBUWS9lbCtmKytrSFQ1MXJXbWhpK2dBR2dnQUlHZ0FJS0dBQUtLR0FBS0tDQUFhQ0FBZ2FBQWdvWUFBb29ZQUFvb0lBQm9NQ002Z3RNZHVuQzFhKytlVXAwM3Z5Rk82TGM4UFkxVWE1SzFSSlI2K2VtUzA0Yk5tYkxRUS9jUFNkNlg5TEZyRTJkYk9IcTB4ZCtKc29kZlA3MUtOZGE2NFdyVk5WN212NDl1TzdINzBmdlMrb0xpK1pGNzlVZlgyejUxTnhVVytEeUJRd0FCUlF3QUJSUXdBQlFRQUVEUUFFRkRBQUZGREFBRkZEQUFGQkFBUU5BQVFVTUFBV20zQkpXLzl4czJXaGUvNndvZDJEMFNKVDc5ZkFOVVc1ZHVJUzE4dHZaWWt5NjVOVGFyY01QUkxrN0w3cGxuRzh5TVY3YnVpaktiZGlZVFF5bGkxbWRUaWRhTmpyNC9PdlJlYmMvY2tmMDBLRmJ0a1M1S2tQclYwVzVsWnNmRytlYmpNMUR0MTBSNWM2Lytxb29kK2xOOXpWZDFrcDk2YktGMFh2Nm02ZXo4M3BsTWNzWE1BQVVVTUFBVUVBQkEwQUJCUXdBQlJRd0FCUlF3QUJRUUFFRFFBRUZEQUFGRkRBQUZKaHlTMWlwQTZOSG9zV1liMTI1SUR2d3ZTdzJ2SDFObEV1WHNKWnZXeHZsZG9UTFJsVUxWMi9kZFdNV0RKZU5sdlQxUjdrOWgwZXo1NGJPYVhwYXAvUFpoVE9qM0Y5ZU90cjR5Wm4wNTVmK1Bsb3ZYRlV0Wm4zM0YwdWkzSGUra3AxMzZVMzNSYm4wNzlYbEY1OFY1Y1poZ1N0YXpPb1Z2b0FCb0lBQ0JvQUNDaGdBQ2loZ0FDaWdnQUdnZ0FJR2dBSUtHQUFLS0dBQUtLQ0FBYUNBSmF3Sk12akZ2VkZ1MXg4dXlBNjhkMzRVVzc0dE95NWR1RnA2OW1CMllHalg2bVZSYm0yWEx4dWxYdHU2S01xdHUvbmhLUGVUbnk2UEZvWnVmK1NPNkx4MEVhMUt0eTljcGE1Wk1CTGxubm91T3k5ZTVLT3IrQUlHZ0FJS0dBQUtLR0FBS0tDQUFhQ0FBZ2FBQWdvWUFBb29ZQUFvb0lBQm9JQUNCb0FDbHJBbXlOY2ZISTV5RDkyV25aY3VadDE2d2RJb2x5NWNyUmhZSE9WU2c0L3VqSEpEZDkwWTVWb3ZHeTNwNjQ5eWV3NlBObjN1bVUxUDYzU203NzQ3VEdZTGErbS9OLzM1dFZhMWNKWDYwWlA3b2x5M0wxeTkvTHZmVjE5aFV2TUZEQUFGRkRBQUZGREFBRkJBQVFOQUFRVU1BQVVVTUFBVVVNQUFVRUFCQTBBQkJRd0FCYVpWWDJDaTljL05sbjdPUDZNdnlyMzg5dUZqWTduUGVFc1hyajY0ZW5YVDU4NCtiMTdUODlZKzhXeVVHMXEvcXVselV3UDNQQnpsV2k5cmJkaDRLTW9OM1p1OTk2bjBmbStGQzJhdHBVdFlXMVpjMHZTNU8zKzRydWw1dmVMeXozOHk2cHFuL3Z5MzZMelJrZjFqdWsrMzhBVU1BQVVVTUFBVVVNQUFVRUFCQTBBQkJRd0FCUlF3QUJSUXdBQlFRQUVEUUFFRkRBQUZabFJmWUtLbEN5b3ZkK0xsb0tvMXNaSUZybXYzN3N1Q1lXN1g2bVZSTGwxZVNxVkxTYW1oY1BGcFQ3aVlsWHAvWDdZUTFnbmY1OVlMVjgxL3prVkxaNE9QN294eVdhclQ2VXl4RmNLcHRuQ1Y4Z1VNQUFVVU1BQVVVTUFBVUVBQkEwQUJCUXdBQlJRd0FCUlF3QUJRUUFFRFFBRUZEQUFGcHR3U1ZxcHFrYVYvYnJ6QUZWa3hzRGpLUGQ3MHFmbkNWYmVyV2w1YWQvT09LRGU4ZmMwNDMyUmlWUDJjdTkxVVc0YWFhbndCQTBBQkJRd0FCUlF3QUJSUXdBQlFRQUVEUUFFRkRBQUZGREFBRkZEQUFGQkFBUU5BQVV0WWpJdDNYemtRNWE3ZHU2L3BjMS9kYzdEcGVhbVZteCtMY252RytSNGYrOXpEbzFGdVNWOS9sQnNheTJYR0lQMDV3MlRnQ3hnQUNpaGdBQ2lnZ0FHZ2dBSUdnQUlLR0FBS0tHQUFLS0NBQWFDQUFnYUFBZ29ZQUFwWXd1cHhqMSt3b1BvSy8xZnIrODF1ZWxvdVhacjY4aFUvajNMRDI5ZU41VG9uYkdqOXFwTG5wdEw3dFY1RWUrS3RGNXFlQjUyT0wyQUFLS0dBQWFDQUFnYUFBZ29ZQUFvb1lBQW9vSUFCb0lBQ0JvQUNDaGdBQ2loZ0FDZ3dyZm9DZkZqLzNQbHA5RmdTV25yMjRJbGY1aU9zR0ZqYzlMeHV0NlN2UDhxMVhzSTZ1RHRid2txZm0vNDdla1g2YzBtbFMxalB2TEVyUFRMNjJ6czZzajg5ajBuSUZ6QUFGRkRBQUZCQUFRTkFBUVVNQUFVVU1BQVVVTUFBVUVBQkEwQUJCUXdBQlJRd0FCU1lVWDJCcVNKZHVEcDE1dXdvOTk3UmQ4ZHluUk9XTGdKVkxXYnRXcjBzeWcwK3VqUEtiWDUxT01wZGYyNzJjMGtYcnJyZDBQcFZVVzdsNXNlaVhPdmxxbFQ2UHNONDhBVU1BQVVVTUFBVVVNQUFVRUFCQTBBQkJRd0FCUlF3QUJSUXdBQlFRQUVEUUFFRkRBQUZMR0dOVWJwd05XZlc2Vkh1MEpGM2ppVzVwV2NQUnVkVmFiMlkxWHJoS2oydnM3WHRVbEs2K0pUKy9OWi83b3F4WE9kL3BBdFhBL2M4SE9XMk5QNjlwU3hjTVJuNEFnYUFBZ29ZQUFvb1lBQW9vSUFCb0lBQ0JvQUNDaGdBQ2loZ0FDaWdnQUdnZ0FJR2dBTFRxaS9RU3JwSTFkcXBNMmRIdWZlT3ZsdXljUFhPM0xsUjd2U1JrYWJQcmRMM2pkdWkzT0d0RDBhNTY4L05GcFZHUjc4VzVWS3RsOFJhYTcxTTFpdkxWYys4c1N1TlJuOTdSMGYybi9obDZIcStnQUdnZ0FJR2dBSUtHQUFLS0dBQUtLQ0FBYUNBQWdhQUFnb1lBQW9vWUFBb29JQUJvRURYTDJHbEMxZHpacDBlNVE0ZGVTZGFwR3F0MnhldXVuMHg2emdXaHBpRVd2Ly9xR0lKaStQaEN4Z0FDaWhnQUNpZ2dBR2dnQUlHZ0FJS0dBQUtLR0FBS0tDQUFhQ0FBZ2FBQWdvWUFBcjB6QkpXcDlPSkZxNTZaWEVuVmJWd1ZiVmNsZjUrVnd3c2J2cmMrM2R2UzZPdC84OUY3LzJpVDh4cS9Oak1pLzg0VXZMY1NjQVNGcjZBQWFDQ0FnYUFBZ29ZQUFvb1lBQW9vSUFCb0lBQ0JvQUNDaGdBQ2loZ0FDaWdnQUdnd0pSYndxTHJwTzlnci94K1M1YXdKb0d1LzF0VXdSSldiL01GREFBRkZEQUFGRkRBQUZCQUFRTkFBUVVNQUFVVU1BQVVVTUFBVUVBQkEwQUJCUXdBQldaVVg2QWhTenE5emUvM28wMnBuNHRsS0hxSkwyQUFLS0NBQWFDQUFnYUFBZ29ZQUFvb1lBQW9vSUFCb0lBQ0JvQUNDaGdBQ2loZ0FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFnRWIrQS80S0tqLzRPL1psQUFBQUFFbEZUa1N1UW1DQyIgeD0iMCIgeT0iMCIgd2lkdGg9IjM1MHB4IiBoZWlnaHQ9IjM1MHB4IiAvPjxpbWFnZSBocmVmPSJkYXRhOmltYWdlL3BuZztiYXNlNjQsaVZCT1J3MEtHZ29BQUFBTlNVaEVVZ0FBQWVBQUFBSGdDQVlBQUFCOTFMNlZBQUFBQVhOU1IwSUFyczRjNlFBQUN6QkpSRUZVZUp6dDNFMkwzdVVkaHVGbm1ra3dpWmtReVVJUlFsK0VhQ2xTQ3ZGbDNZVVVQMFNFdXU2dWEzSGRuZXNzNGpmb0pnUVhYY2Nta0JhUlJrRnJTUW02Q0FrWm5VeklTOU9GRzFzQy9qVFB6RG1aT1k3MXpmKzVCd1pPN3MyMXNnRFlaZGFPbjZpdndCNjJmdjNxNk54UHR2Z2VBTUFqQ0RBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNLelVGd0NZbWk1Y3ZmRFV3ZEc1eis1c1BueWMrN0MzdlBEVXdWRXpQN3V6T2ZxZUZ6QUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDQWd3QUFSVzZ3c0FMTnQwNGVvUHp6MC8rdDU3WDE0Ym5mTzlKL043VSs5OWVXMjZuRFphelBJQ0JvQ0FBQU5BUUlBQklDREFBQkFRWUFBSUNEQUFCQVFZQUFJQ0RBQUJBUWFBd0dpdEEyQW5XRHQrWW5UdStRTUhSdWV1M2IwN1dqYjYyYTkrTi9yZUZ4K2ZINTNiNmQ4N2UvTFk2Tnhibjk3Y0ZkK2JldjdBZ1ZFenI5MjlPL3FlRnpBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFzWVFHN3puUXhhN0ZZTEhVSmE3ZDQ1OTZIOVJXMjFROVl6Qm8xYy8zNjFkSEh2SUFCSUNEQUFCQVFZQUFJQ0RBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQ3dXbDhBZ0VjN2Qvcks2TnliNzcrMHhUZDV0RmZlUHByODdzVXp0NUxmWFRZdllBQUlDREFBQkFRWUFBSUNEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0ZqQ0F0aG0wNFdyWlg5dnVwZzFYYmlxRnFsMit2Mm12SUFCSUNEQUFCQVFZQUFJQ0RBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQmdDUXRnbTAwWHFkamR2SUFCSUNEQUFCQVFZQUFJQ0RBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQmdDUXRnaHpwMytzcm9uR1d0SjVNWE1BQUVCQmdBQWdJTUFBRUJCb0NBQUFOQVFJQUJJQ0RBQUJBUVlBQUlDREFBQkN4aEFXeXo2Y0xWc3I4M1hjeTZlT2JXNk53cmJ4OGRuVnUyNmYxMk9pOWdBQWdJTUFBRUJCZ0FBZ0lNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkFRWUFBSVdNSUMyR2JUUmFxZGJyY3NVbFc4Z0FFZ0lNQUFFQkJnQUFnSU1BQUVCQmdBQWdJTUFBRUJCb0NBQUFOQVFJQUJJR0FKQytCN3ZIUHZ3L29LMityZC9hL1ZWOWhtNTVOZjlRSUdnSUFBQTBCQWdBRWdJTUFBRUJCZ0FBZ0lNQUFFQkJnQUFnSU1BQUVCQm9DQUpTeUFiZmJLMjBlVDM3MTQ1bGJ5dStkT1h4bWRlL1A5bDdiNEpqdUxGekFBQkFRWUFBSUNEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBUXNZUUVzeVhUaHFscWtHaTl3dlQ4N05sMjRtdHByaTFsZXdBQVFFR0FBQ0Fnd0FBUUVHQUFDQWd3QUFRRUdnSUFBQTBCQWdBRWdJTUFBRUxDRUJjQ1BzbHNXcVNwZXdBQVFFR0FBQ0Fnd0FBUUVHQUFDQWd3QUFRRUdnSUFBQTBCQWdBRWdJTUFBRUxDRUJleFpwNDdzWDVtY2UrdlRtdzhuNS82eE9QcDRGOXFsenAyK01qcTM3R1d0THo0K1B6cDNlTzNaMGYvQnh2cFhqM1dmLytjRkRBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDQWd3QUFRRUdBQUNBZ3dBZ2RINkI4QnV0SGI4eE9qY0d5OGZHcDM3NEtQYnM4V3NQLzEwOUwxbHUzam0xdWpjdS90Zkc1MmJMbHd0MnkvLytLL1J1V1V2WEsxZnZ6bzZOK1VGREFBQkFRYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBVXRZQU4raldzdzZlL0xZNkh2TE5sM0NXcll2UGo0L092Zkd5NGRHN2ZyZ285dWo3eTE3NFdyS0N4Z0FBZ0lNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkFRWUFBSUNEQUFCQVFZQUFLV3NBQ1daTHFZZGVySS90RzVTMS9mU3hhemxyMkVOVjI0T3J6MjdLaEpHK3RmamI1WExWeE5lUUVEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwREFFaGJBTnBzdVpyMTRjSFYwN3BQTiswdGR6Sm91WVUwWHJwNDYvTXlvTlhjMmJveSt0OU1YcnFhOGdBRWdJTUFBRUJCZ0FBZ0lNQUFFQkJnQUFnSU1BQUVCQm9DQUFBTkFRSUFCSUdBSkMyQ0htaTVtTFJhTDBSSldhTlNhM2JKd05lVUZEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBUUVHQUFDQWd3QWdkWDZBZ0JzajFOcnp5ejFlNWZXYnl6MWUzdU5GekFBQkFRWUFBSUNEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBUXNZUUhzRWE4ZlBqZzZkMkZqYzR0dndtTGhCUXdBQ1FFR2dJQUFBMEJBZ0FFZ0lNQUFFQkJnQUFnSU1BQUVCQmdBQWdJTUFJR1YrZ0lBZTgzYThST2pjeThlbkkwVmZySjUvK0hqM0dlckhkbTNPbXJOMXcvdWo3NjNmdjNxWTkxbnAvQUNCb0NBQUFOQVFJQUJJQ0RBQUJBUVlBQUlDREFBQkFRWUFBSUNEQUFCQVFhQXdHeG1CWUJ0TjEyNE9udnkyRkovOS9MNm9kRzVDeHVibzNPWDFtOU1sN3IyMURxakZ6QUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDQWd3QUFRc1lRSHNVS2VPN0I4dFE3MzE2YzNwMHRUUXphVis3Y2krMWRIZjhmV0QrMHY5M1ozT0N4Z0FBZ0lNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkFRWUFBSUNEQUFCQVFZQUFLamRSSUF0dC9hOFJPamM2OCtmV1IyN3NqYWFESHJ3c2JtNkh1WDFtK016aTJHclZtL2ZuWDZ2VjNCQ3hnQUFnSU1BQUVCQm9DQUFBTkFRSUFCSUNEQUFCQVFZQUFJQ0RBQUJBUVlBQUtyOVFVQWVMVHBNdFNyejcyK3hUZDV0RjhjZkhxMGNQWDU1amRiZlpVbmtoY3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnSU1BQUVCQmdBQWdJTUFBRUxHRUI3RkJyeDArTXp0MTZjSHQwN3VpK1E2TnpyeDVlSFMxYy9YVmo5TG5GMy80OVcvVGFhN3lBQVNBZ3dBQVFFR0FBQ0Fnd0FBUUVHQUFDQWd3QUFRRUdnSUFBQTBCQWdBRWdNRm83QVdEN1RaZXdGb3ZGdzhtaHN5ZVBqVDUyODk2K1VSdCtmL0h5NkhzOG1oY3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnSU1BQUVCQmdBQWdJTUFBRVZ1c0xBTEN6M1A3UGc5RzUzLzc4MTZOemYvbm4zeC9uT3J1V0Z6QUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDQWd3QUFRc1lRSHdQLzU4WStYaDVOeU5lM2RYSnVmV2pwOFkvZTc2OWF1amM3dUZGekFBQkFRWUFBSUNEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBUXNZUUh3bzN5KytjMW9NV3V4V0l3V3MvWWFMMkFBQ0Fnd0FBUUVHQUFDQWd3QUFRRUdnSUFBQTBCQWdBRWdJTUFBRUJCZ0FBZ0lNQUFFQkJnQUFnSU1BQUVCQm9DQUFBTkFRSUFCSUNEQUFCQVFZQUFJQ0RBQUJBUVlBQUlDREFBQkFRYUFnQUFEUUVDQUFTQWd3QUFRRUdBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnSU1BQUVCQmdBQWdJTUFBRUJCZ0FBZ0lNQUFFQkJvQ0FBQU5BUUlBQklDREFBQkFRWUFBSUNEQUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDS3pXRndCZ2UxeGVQelE4dWJtbDkrQmJYc0FBRUJCZ0FBZ0lNQUFFQkJnQUFnSU1BQUVCQm9DQUFBTkFRSUFCSUNEQUFCQ3doQVd3Ui94bTdmYm8zSVdObFMyK0NZdUZGekFBSkFRWUFBSUNEQUFCQVFhQWdBQURRRUNBQVNBZ3dBQVFFR0FBQ0Fnd0FBUXNZUUhzRVpmWER3MVBibTdwUGZpV0Z6QUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDQWd3QUFRRUdBQUNBZ3dBQVFFR2dJQUFBMEJBZ0FFZ0lNQUFFQkJnQUFnSU1BQUVCQmdBQWdJTUFJSFYrZ0lBYkk4TEc1djFGZmdPTDJBQUNBZ3dBQVFFR0FBQ0Fnd0FBUUVHZ0lBQUEwQkFnQUVnSU1BQUVCQmdBQWhZd2dMWUl5NnQzNml2d0hkNEFRTkFRSUFCSUNEQUFCQVFZQUFJQ0RBQUJBUVlBQUlDREFBQkFRYUFnQUFEUU1BU0ZzQ1RiNlcrQUQrY0Z6QUFCQVFZQUFJQ0RBQUJBUWFBZ0FBRFFFQ0FBU0Fnd0FBUUVHQUFDQWd3QUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQXdKTDhGL0xGTDczcmN2N2FBQUFBQUVsRlRrU3VRbUNDIiB4PSIwIiB5PSIwIiB3aWR0aD0iMzUwcHgiIGhlaWdodD0iMzUwcHgiIC8+PGltYWdlIGhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBZUFBQUFIZ0NBWUFBQUI5MUw2VkFBQUFBWE5TUjBJQXJzNGM2UUFBQmRGSlJFRlVlSnp0M0wxcWsyRWN4dUhZT1BnQlhkb3BneGdkaEFnT2l0WWcyUVJyRmhkUHdVTndyN09INENtNHVNUUticUdFS2pvb0ZodzA0dERKTG9JZlM5UVRxUEtIUnU1OFhOZjg4T1FscGZueExuZWpBUUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU15dVkra0hBRmhkUDVOK2hLbjQrdVZ6K2hHWUl5dnBCd0NBWlNUQUFCQWd3QUFRSU1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBZ3dBQVFjRHo5QUN3M0MwaUxyZnIzN2F3MVMrZjJEaWEvai9JOFIyQTFrS256Qmd3QUFRSU1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBZ3dBQVFJTUFBRUNEQUFCbHJDWUY1RUZwRjY3V1ZwQUdqWnFpMDhXc3c1WFhiamF1bkc2ZE4vV3pyZnFSMXU0SXNZYk1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBZ3dBQVFJTUFBRUNEQUFCQWd3QUFSWXdtSmVWQmVMU290SzIvZE9saTdiZlBTamRGKy8yeW85MzJCVSt0aVpYOHhhWGE4dGYxMDlkNkowN3VYSG42VnoxenUvU3VjYU83VmpWYlArOTJBK2VRTUdnQUFCQm9BQUFRYUFBQUVHZ0FBQkJvQUFBUWFBQUFFR2dBQUJCb0FBQVFhQWdPcTZFRVJWbDVkNjdXYnAzSEE4S1MxY2pSL2ZLZDNYdnZ1a2RHN2oycFhTLzl6dWkxZWwrMUkyTHE2Vnp1MitPeWg5ejNzUHo1YnU2OXovVkRyWGF6ZEwzL053UENuZFp3bUwvOEViTUFBRUNEQUFCQWd3QUFRSU1BQUVDREFBQkFnd0FBUUlNQUFFQ0RBQUJBZ3dBQVJZd21LaFZCZXordDFXNmR4Z3RGOWFjdnJ3L25YcHZ2TVhMcGZPTFlwcEw0bmR1blNxOUp2MTdNMzMwbjBXcmtqeUJnd0FBUUlNQUFFQ0RBQUJBZ3dBQVFJTUFBRUNEQUFCQWd3QUFRSU1BQUVDREFBQmxyQllTdFhGck51Yk4wdm5ubTQvbitwaTFyU3R2SDBRK2R6cXdsVy8yeXI5RmcxRys2WDdMRnd4RDd3QkEwQ0FBQU5BZ0FBRFFJQUFBMENBQUFOQWdBQURRSUFBQTBDQUFBTkFnQUFEUUlBbExQaUgxR0xXb3JCd0JYL25EUmdBQWdRWUFBSUVHQUFDQkJnQUFnUVlBQUlFR0FBQ0JCZ0FBZ1FZQUFJRUdBQUNMR0hCRkZRWHN6aWNoU3VXa1RkZ0FBZ1FZQUFJRUdBQUNCQmdBQWdRWUFBSUVHQUFDQkJnQUFnUVlBQUlFR0FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFDWU0zOEE4K3hydHVVdzJHNEFBQUFBU1VWT1JLNUNZSUk9IiB4PSIwIiB5PSIwIiB3aWR0aD0iMzUwcHgiIGhlaWdodD0iMzUwcHgiIC8+PC9zdmc+", 
                "image bytes are incorrect"
            );
        }
    }


    mod test_construct_json_attributes {
        use super::super::{construct_json_attributes};
        use blob::generation::{
            armour::{armours}, mask::{masks}, background::{backgrounds},
            jewellry::{jewellries}, weapon::{weapons}
        };

        #[test]
        fn test_construct_json_attributes() {
            let (_, armour_name) = armours(2);
            let (_, mask_name) = masks(1);
            let (_, background_name) = backgrounds(2);
            let (_, jewellry_name) = jewellries(3);
            let (_, weapon_name) = weapons(1);


            let blobert_attributes = construct_json_attributes(
                armour: armour_name, 
                mask: mask_name, 
                background: background_name, 
                jewellry: jewellry_name, 
                weapon: weapon_name
            );

            let precalculated_attrs: Span<ByteArray> = array![
                "{\"trait\":\"Armour\",\"value\":\"Divine Robe\"}",
                "{\"trait\":\"Mask\",\"value\":\"Doge\"}",
                "{\"trait\":\"Background\",\"value\":\"Fidenza\"}",
                "{\"trait\":\"Jewellry\",\"value\":\"Necklace\"}",
                "{\"trait\":\"Weapon\",\"value\":\"Banner\"}"
            ].span();

            let mut count = 0;
            loop {
                if count == 5 {
                    break;
                }

                assert!(
                    blobert_attributes[count] == precalculated_attrs[count],
                    "json attributes are incorrect"
                );

                count += 1;
            };
        }
    }
}
