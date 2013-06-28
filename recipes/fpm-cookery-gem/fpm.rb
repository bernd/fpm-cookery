class FpmRubyGem < FPM::Cookery::RubyGemRecipe
  name    "fpm"
  version "0.4.39"

  chain_package true
  chain_recipes "json", "cabin", "backports", "arr-pm", "clamp", "childprocess", "ftw"
end
