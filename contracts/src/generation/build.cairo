use graffiti::elements::TagBuilder;
use graffiti::{Tag, TagImpl};

use blob::generation::{
    armour::{get_armour}, masks::{get_masks}, background::{get_background},
    jewellry::{get_jewellry}, weapons::{get_weapon}
};


fn blobert(seed: u32) -> ByteArray {
    let root: Tag = TagImpl::new("svg")
        .attr("xmlns", "http://www.w3.org/2000/svg")
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 350 350");

    let body: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + get_armour(seed))
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let head: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + get_masks(seed))
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let background_one: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + get_background(seed))
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let jewellry_one: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + get_jewellry(seed))
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let weapon_one: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + get_weapon(seed))
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    root
        .insert(background_one)
        .insert(head)
        .insert(body)
        .insert(weapon_one)
        .insert(jewellry_one)
        .build()
}

#[cfg(test)]
mod tests {
    use super::{blobert};

    #[test]
    #[available_gas(1000000000)]
    fn test_add() {
        let blob = blobert(900);

        println!("blob: {}", blob);
    }
}
