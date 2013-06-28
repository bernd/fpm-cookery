class FtwRubyGem < FPM::Cookery::RubyGemRecipe
  name    "ftw"
  version "0.0.34"

  chain_package true
  chain_recipes "http_parser.rb"
end
