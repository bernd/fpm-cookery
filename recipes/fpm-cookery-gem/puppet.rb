class PuppetRubyGem < FPM::Cookery::RubyGemRecipe
  name    "puppet"
  version "3.4.3"

  chain_package true
  chain_recipes "hiera", "rgen"
end
