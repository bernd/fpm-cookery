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
    cleanenv_safesystem "#{destdir}/bin/gem install #{name} -v #{version}"
  end

  def install
    # Do nothing!
  end
end
