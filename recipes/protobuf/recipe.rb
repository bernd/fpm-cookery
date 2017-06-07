class Protobuf < FPM::Cookery::Recipe
  homepage 'https://developers.google.com/protocol-buffers/'

  source   'https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz'
  md5      'f3916ce13b7fcb3072a1fa8cf02b2423'

  name     'protobuf'
  version  '2.6.1'

  description 'Google\'s data interchange format'

  conflicts 'protobuf'

  def build
    configure \
        :prefix => prefix
    make
  end

  def install
    make :install, 'DESTDIR' => destdir
  end
end
