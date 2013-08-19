class HieraRubyGem < FPM::Cookery::RubyGemRecipe
  name    "hiera"
  version "1.2.1"

  chain_package true
  chain_recipes "json_pure"
end
