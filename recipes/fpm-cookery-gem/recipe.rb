class FpmCookeryRubyGem < FPM::Cookery::RubyGemRecipe
  name    "fpm-cookery"
  version "0.15.0"

  chain_package true
  chain_recipes "fpm", "facter", "puppet", "addressable"
end
