use blob::generation::traits::mask;

fn masks() -> Array<(ByteArray, ByteArray)> {
    return array![
            (mask::blobert(), "Blobert"),
            (mask::doge(), "Doge"),
            (mask::dojo(), "Dojo"),
            (mask::ducks(), "Ducks"),
            (mask::influence(), "Influence"),
            (mask::kevin(), "Kevin"),
            (mask::milady(), "Milady"),
            (mask::pepe(), "Pepe"),
            (mask::pudgy(), "Pudgy"),
            (mask::smol(), "Smol")
        ];
}