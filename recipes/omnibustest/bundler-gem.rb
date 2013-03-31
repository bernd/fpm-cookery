class BundlerGem < FPM::Cookery::Recipe
  description 'Bundler gem'

  name 'bundler'
  version '1.3.4'
  revision 0
  source "nothing", :with => :noop

  vendor     'fpm'
  license    'Unknown'

  section 'interpreters'

  def build
    Bundler.with_clean_env do 
      safesystem "/opt/omnibustest/embedded/bin/gem install bundler"
    end
  end

  def install
    # Do nothing!
  end
end
