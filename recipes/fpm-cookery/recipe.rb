require 'fpm/cookery/utils/ruby'
class FPMCookery < FPM::Cookery::Recipe
  description 'building packages'

  name     'fpm-cookery'
  version  '0.16.2'
  revision 0
  homepage 'https://github.com/bernd/fpm-cookery'
  license  'MIT'

  source '', :with => :noop

  omnibus_package true
  omnibus_recipes 'ruby'
  omnibus_dir     '/opt/fpm-cookery'

  include FPM::Cookery::Utils::Ruby

  def build
  end

  def install
    ruby.gem('install','fpm-cookery','-v',version,'--no-document')
    destdir('bin').install workdir('fpm-cook.bin'), 'fpm-cook'

    with_trueprefix do
      create_post_install_hook
      create_pre_uninstall_hook
    end
  end

  private

  def create_post_install_hook
    File.open(builddir('post-install'), 'w', 0755) do |f|
      f.write <<-__POSTINST
#!/bin/sh
set -e

BIN_PATH="#{real.bin}"
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

BIN_PATH="#{real.bin}"
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
