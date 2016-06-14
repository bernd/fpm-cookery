class Redis < FPM::Cookery::Recipe
  def build
    make

    inline_replace 'redis.conf' do |s|
      s.gsub! 'daemonize no', 'daemonize yes # non-default'
    end
  end

  def install
    # C'mon, redis, what's up with not respecting DESTDIR?
    make :install, 'PREFIX' => destdir / 'usr'

    var('lib/redis').mkdir

    %w(run log/redis).each {|p| var(p).mkdir }

    bin.install ['src/redis-server', 'src/redis-cli']

    etc('redis').install 'redis.conf'
    etc('init.d').install workdir('redis-server.init.d') => 'redis-server'
  end
end
