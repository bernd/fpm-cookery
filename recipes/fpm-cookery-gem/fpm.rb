class FpmRubyGem < FPM::Cookery::RubyGemRecipe
  name    "fpm"
  version "0.4.29"

  chain_package true
  chain_recipes "json", "cabin", "backports", "arr-pm", "clamp", "open4"
end
