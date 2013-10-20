require 'fpm/cookery/utils/ruby'
class BundlerGem < FPM::Cookery::Recipe
  description 'Bundler gem'

  name 'bundler'
  version '1.3.4'
  revision 0
  source "nothing", :with => :noop

  vendor     'fpm'
  license    'Unknown'

  section 'interpreters'

  include FPM::Cookery::Utils::Ruby

  def build
  end

  def install
    ruby.gem('install','bundler:1.3.4','--no-document')
  end
end
