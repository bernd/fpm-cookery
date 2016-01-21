class Httpie < FPM::Cookery::VirtualenvRecipe
  description 'user-friendly cURL replacement featuring intuitive UI, JSON support, syntax highlighting'

  name     'httpie'
  version  '0.9.2'
  revision '1'
  arch     'all'

  homepage   'http://httpie.org'

  build_depends 'python-virtualenv', 'python-setuptools'

  virtualenv_fix_name         false
  virtualenv_install_location '/opt'
end
