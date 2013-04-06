class Ruby200 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name 'ruby'
  version '2.0.0.0'
  revision 0
  homepage 'http://www.ruby-lang.org/'
  source 'http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p0.tar.bz2'
  sha256 'c680d392ccc4901c32067576f5b474ee186def2fcd3fcbfa485739168093295f'

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
