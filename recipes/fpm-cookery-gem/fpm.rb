class FpmRubyGem < FPM::Cookery::RubyGemRecipe
  name    "fpm"
  version "1.1.0"

  chain_package true
  chain_recipes "json", "cabin", "backports", "arr-pm", "clamp", "childprocess"
end
