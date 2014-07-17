class Ruby210 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name 'ruby'
  version '2.1.2'
  revision 0
  homepage 'http://www.ruby-lang.org/'
  source 'http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.bz2'
  sha256 '6948b02570cdfb89a8313675d4aa665405900e27423db408401473f30fc6e901'

  vendor     'fpm'
  license    'The Ruby License'

  section 'interpreters'

  build_depends 'autoconf', 'libreadline6-dev', 'bison', 'zlib1g-dev',
                'libssl-dev', 'libyaml-dev', 'libffi-dev', 'libgdbm-dev', 'libncurses5-dev',
                'libreadline6-dev'

  depends 'libffi6', 'libncurses5', 'libreadline6', 'libssl1.0.0',
          'libtinfo5', 'libyaml-0-2', 'zlib1g', 'libffi6', 'libgdbm3', 'libncurses5',
          'libreadline6'

  def build
    configure :prefix => destdir, 'disable-install-doc' => true
    make
  end

  def install
    make :install
  end
end
