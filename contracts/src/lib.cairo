mod descriptor;
mod blobert;
mod seeder;
mod types;
mod utils {
    mod encoding;
    mod randomness;
}
mod generation {
    mod custom;
    mod traits {
        mod armour;
        mod background;
        mod jewellry;
        mod mask;
        mod weapon;
        mod data {
            mod armour;
            mod background;
            mod jewellry;
            mod mask;
            mod weapon;
        }
    }
}
mod tests {
    mod contracts {
        mod erc20;
    }
    mod unit_tests {
        mod test_blobert;
        mod utils;
    }
}
