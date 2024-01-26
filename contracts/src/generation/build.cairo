use graffiti::elements::TagBuilder;
use graffiti::{Tag, TagImpl};

use blob::generation::{
    body::{body_one}, head::{head_one}, background::{background_one}, jewellry::{jewellry_one},
    weapons::{weapon_one}
};


fn blobert() -> ByteArray {
    let root: Tag = TagImpl::new("svg")
        .attr("xmlns", "http://www.w3.org/2000/svg")
        .attr("preserveAspectRatio", "xMinYMin meet")
        .attr("viewBox", "0 0 350 350");

    let body: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + body_one())
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let head: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + head_one())
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let background_one: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + background_one())
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let jewellry_one: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + jewellry_one())
        .attr("x", "0")
        .attr("y", "0")
        .attr("width", "350px")
        .attr("height", "350px");

    let weapon_one: Tag = TagImpl::new("image")
        .attr("href", "data:image/png;base64," + weapon_one())
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
        let blob = blobert();

        println!("blob: {}", blob);
    }
}
