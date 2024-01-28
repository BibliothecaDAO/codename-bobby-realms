use graffiti::elements::TagBuilder;
use graffiti::{Tag, TagImpl};

use blob::generation::{
    armour::{get_armour}, masks::{get_masks}, background::{get_background},
    jewellry::{get_jewellry}, weapons::{get_weapon}
};
use graffiti::json::JsonImpl;

#[derive(Drop)]
struct Traits {
    mask: ByteArray,
    armour: ByteArray,
    weapon: ByteArray,
    jewellry: ByteArray,
    background: ByteArray,
}

fn blobert(seed: u32) -> (ByteArray, Traits) {
    let root: Tag = TagImpl::new("svg")
        .attr("xmlns", "http://www.w3.org/2000/svg")
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 350 350");

    // get images and traits
    let (armour_image, armour_name) = get_armour(seed);
    let (mask_image, mask_name) = get_masks(seed);
    let (background_image, background_name) = get_background(seed);
    let (jewellry_image, jewellry_name) = get_jewellry(seed);
    let (weapon_image, weapon_name) = get_weapon(seed);

    let armour: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + armour_image)
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let mask: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + mask_image)
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let background: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + background_image)
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let jewellry: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + jewellry_image)
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let weapon: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + weapon_image)
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    (
        root.insert(background).insert(mask).insert(armour).insert(weapon).insert(jewellry).build(),
        Traits {
            mask: JsonImpl::new().add("trait_type", "Armour").add("value", armour_name).build(),
            armour: JsonImpl::new().add("trait_type", "Mask").add("value", mask_name).build(),
            weapon: JsonImpl::new()
                .add("trait_type", "Background")
                .add("value", background_name)
                .build(),
            jewellry: JsonImpl::new()
                .add("trait_type", "Jewellry")
                .add("value", jewellry_name)
                .build(),
            background: JsonImpl::new()
                .add("trait_type", "Weapon")
                .add("value", weapon_name)
                .build(),
        }
    )
}

#[cfg(test)]
mod tests {
    use super::{blobert};

    #[test]
    #[available_gas(1000000000)]
    fn test_add() {
        let (blob, _) = blobert(900);

        println!("blob: {}", blob);
    }
}
