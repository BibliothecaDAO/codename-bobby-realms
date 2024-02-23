mod blobert;
mod seeder;
mod types;
mod descriptor {
    mod descriptor_custom;
    mod descriptor_regular;
}
mod utils {
    mod encoding;
    mod randomness;
}
mod generation {
    mod custom {
        mod image;
        mod data {
            mod images;
        }
    }
    mod traits {
        mod armour;
        mod background;
        mod jewelry;
        mod mask;
        mod weapon;
        mod data {
            mod armour;
            mod background;
            mod jewelry;
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
        mod test_descriptor_custom;
        mod test_descriptor_regular;
        mod test_seeder;
        mod test_types;
        mod utils;
    }
    mod fork_tests {
        mod test_blobert_fork;
    }
}
