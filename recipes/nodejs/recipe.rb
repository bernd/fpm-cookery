class NodeJS < FPM::Cookery::Recipe
  source 'http://nodejs.org/dist/node-v0.4.10.tar.gz'
#  head 'https://github.com/joyent/node.git'
  homepage 'http://nodejs.org/'
  md5 '2e8b82a9788308727e285d2d4a129c29'

  section 'interpreters'
  name 'nodejs'
  version '0.4.10+github1'
  description 'Evented I/O for V8 JavaScript'

  build_depends \
    'libssl-dev',
    'g++',
    'python'

  depends \
    'openssl'

  def build
    inreplace 'wscript' do |s|
      s.gsub! '/usr/local', '/usr'
      s.gsub! '/opt/local/lib', '/usr/lib'
    end

    configure \
      :prefix => prefix,
      :debug => true
    make
  end

  def install
    make :install, 'DESTDIR' => destdir
  end
end
