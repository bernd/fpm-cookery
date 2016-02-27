class Redis < FPM::Cookery::Recipe
  def build
    make

    inline_replace 'redis.conf' do |s|
      s.gsub! 'daemonize no', 'daemonize yes # non-default'
    end
  end

  def install
     make :install, 'DESTDIR' => destdir

    var('lib/redis').mkdir

    %w(run log/redis).each {|p| var(p).mkdir }

    bin.install ['src/redis-server', 'src/redis-cli']

    etc('redis').install 'redis.conf'
    etc('init.d').install workdir('redis-server.init.d') => 'redis-server'
  end
end
