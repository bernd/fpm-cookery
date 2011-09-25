class Redis < FPM::Cookery::Recipe
  homepage 'http://redis.io'
  source   'http://redis.googlecode.com/files/redis-2.2.5.tar.gz'
  md5      'fe6395bbd2cadc45f4f20f6bbe05ed09'

  name     'redis-server'
  version  '2.2.5'
#  revision '0' # => redis-server-2.2.5+fpm1

  description 'An advanced key-value store.'

  conflicts 'redis-server'

  config_files '/etc/redis/redis.conf'

  patches 'patches/test.patch'

  def build
    make

    inline_replace 'redis.conf' do |s|
      s.gsub! 'daemonize no', 'daemonize yes # non-default'
    end
  end

  def install
    # make :install, 'DESTDIR' => destdir

    var('lib/redis').mkdir

    %w(run log/redis).each {|p| var(p).mkdir }

    bin.install ['src/redis-server', 'src/redis-cli']

    etc('redis').install 'redis.conf'
    etc('init.d').install workdir('redis-server.init.d') => 'redis-server'
  end
end
