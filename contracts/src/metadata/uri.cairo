use blob::generation::build;

use graffiti::json::JsonImpl;

use alexandria_encoding::base64::Base64Encoder;

fn uri(seed: u32) -> ByteArray {
    let (image, attributes) = build::blobert(1000);

    let encoded = "data:image/png;base64," + _base64_encode(image);

    let mainarr = JsonImpl::new()
        .add("name", "John")
        .add("description", "Blobert ")
        .add_array(
            "attributes",
            array![
                attributes.mask.clone(),
                attributes.background.clone(),
                attributes.weapon.clone(),
                attributes.jewellry.clone(),
                attributes.armour.clone()
            ]
                .span()
        )
        .add("image", encoded);

    let z = mainarr.build();

    "data:application/json;base64," + _base64_encode(z)
}


fn _base64_encode(abc: ByteArray) -> ByteArray {
    let mut arr: Array<u8> = array![];
    let mut count = 0;
    loop {
        if count == abc.len() {
            break;
        }

        match abc.at(count) {
            Option::Some(x) => { arr.append(x); },
            Option::None => { break; }
        }
        count += 1;
    };

    //
    let result = Base64Encoder::encode(arr);

    let mut j = 0;
    let mut f: ByteArray = "";

    loop {
        if j == result.len() {
            break;
        }

        // f = format!("{}{}",f, );
        f.append_byte(*result[j]);
        j += 1;
    };

    return f;
}

#[cfg(test)]
mod tests {
    use super::{uri};

    #[test]
    #[available_gas(100000000000)]
    fn test_add() {
        let blob = uri(900);

        println!("blob: {}", blob);
    }
}
