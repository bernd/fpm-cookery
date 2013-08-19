class PuppetRubyGem < FPM::Cookery::RubyGemRecipe
  name    "puppet"
  version "3.2.2"

  chain_package true
  chain_recipes "hiera", "rgen"
end
