class Ruby200 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name    'ruby'
  version '2.0.0.195'
  revision 0
  homepage 'http://www.ruby-lang.org/'
  source   'http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p195.tar.bz2'
  sha256   '0be32aef7a7ab6e3708cc1d65cd3e0a99fa801597194bbedd5799c11d652eb5b'

  license 'The Ruby License'
  section 'interpreters'

  platforms [:ubuntu, :debian] do
    build_depends 'autoconf', 'libreadline6-dev', 'bison', 'zlib1g-dev',
                  'libssl-dev', 'libyaml-dev', 'libffi-dev', 'libgdbm-dev',
                  'libncurses5-dev', 'libreadline6-dev'
    depends 'libffi6', 'libncurses5', 'libreadline6', 'libssl1.0.0',
            'libtinfo5', 'libyaml-0-2', 'zlib1g', 'libffi6', 'libgdbm3',
            'libncurses5', 'libreadline6'
  end

  platforms [:fedora, :redhat, :centos] do
    build_depends 'rpmdevtools', 'libffi-devel', 'autoconf', 'bison',
                  'libxml2-devel', 'libxslt-devel', 'openssl-devel',
                  'gdbm-devel', 'zlib-devel'
    depends 'zlib', 'libffi', 'gdbm'
  end
  platforms [:fedora] do depends.push('openssl-libs') end
  platforms [:redhat, :centos] do depends.push('openssl') end

  def build
    configure :prefix => destdir,
              'enable-shared' => true,
              'disable-install-doc' => true
    make
  end

  def install
    make :install

    # Shrink package.
    rm_f "#{destdir}/lib/libruby-static.a"
    safesystem "strip #{destdir}/bin/ruby"
    safesystem "find #{destdir} -name '*.so*' | xargs strip"
  end
end
