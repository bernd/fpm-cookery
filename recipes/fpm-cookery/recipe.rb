class FPMCookery < FPM::Cookery::Recipe
  description 'building packages'

  name     'fpm-cookery'
  version  '0.15.0'
  revision 0
  homepage 'https://github.com/bernd/fpm-cookery'
  license  'MIT'

  source '', :with => :noop

  omnibus_package true
  omnibus_recipes 'ruby'
  omnibus_dir     '/opt/fpm-cookery'

  def build
    gem_install 'fpm-cookery', version
  end

  def install
    destdir('bin').install workdir('fpm-cook.bin'), 'fpm-cook'

    with_trueprefix do
      create_post_install_hook
      create_pre_uninstall_hook
    end
  end

  private

  def gem_install(name, version = nil)
    v = version.nil? ? '' : "-v #{version}"
    cleanenv_safesystem "#{destdir}/embedded/bin/gem install --no-ri --no-rdoc #{v} #{name}"
  end

  def create_post_install_hook
    File.open(builddir('post-install'), 'w', 0755) do |f|
      f.write <<-__POSTINST
#!/bin/sh
set -e

BIN_PATH="#{destdir}/bin"
BIN="fpm-cook"

update-alternatives --install /usr/bin/$BIN $BIN $BIN_PATH/$BIN 100

exit 0
      __POSTINST

      self.class.post_install(File.expand_path(f.path))
    end
  end

  def create_pre_uninstall_hook
    File.open(builddir('pre-uninstall'), 'w', 0755) do |f|
      f.write <<-__PRERM
#!/bin/sh
set -e

BIN_PATH="#{destdir}/bin"
BIN="fpm-cook"

if [ "$1" != "upgrade" ]; then
  update-alternatives --remove $BIN $BIN_PATH/$BIN
fi

exit 0
        __PRERM

      self.class.pre_uninstall(File.expand_path(f.path))
    end
  end
end
