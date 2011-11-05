class Redis < FPM::Cookery::Recipe
  homepage 'http://redis.io'

  # Different source methods.
  #
  #source   'https://github.com/antirez/redis/trunk', :with => :svn
  #source   'https://github.com/antirez/redis/trunk', :with => :svn, :revision => '2400'
  #
  #source   'https://github.com/antirez/redis', :with => :git, :tag => '2.4.2
  #source   'https://github.com/antirez/redis', :with => :git, :branch => '2.4'
  #source   'https://github.com/antirez/redis', :with => :git, :sha => '072a905'

  source    'http://redis.googlecode.com/files/redis-2.4.2.tar.gz'
  md5      'c4b0b5e4953a11a503cb54cf6b09670e'

  name     'redis-server'
  version  '2.4.2'
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
