class OmnibusTest < FPM::Cookery::Recipe
  homepage 'http://test'

  section 'interpreters'
  name 'omnibus-test'
  version '1.0.0'
  description 'Testing Omnibus package'
  revision 0
  source '', :with => :noop

  omnibus_package true
  omnibus_recipes "ruby", "bundler-gem"
  omnibus_dir     '/opt/omnibustest'

  def build
  end

  def install
  end
end
