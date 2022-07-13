class FacterRubyGem < FPM::Cookery::RubyGemRecipe
  name    'facter'
  version '1.6.16'
  epoch 2

  package_name_format 'NAME_EPOCH:FULLVERSION_ARCH.EXTENSION'
end
