class ChildprocessRubyGem < FPM::Cookery::RubyGemRecipe
  name    "childprocess"
  version "0.3.9"

  chain_package true
  chain_recipes "ffi"
end
