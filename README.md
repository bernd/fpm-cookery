# fpm-cookery - For building software

A tool for building software packages with
[fpm](https://github.com/jordansissel/fpm).

The [fpm](https://github.com/jordansissel/fpm) project is really nice for
building operating system packages like `.deb` and `.rpm`. But it only helps
you to create the packages and doesn't help you with actually building the
software.

__fpm-cookery__ provides an infrastructure to automatically build software
based on recipes. It's heavily inspired and borrows code from the great
[homebrew](https://github.com/mxcl/homebrew) and
[brew2deb](https://github.com/tmm1/brew2deb) projects.
The [OpenBSD Ports System](http://www.openbsd.org/faq/ports/index.html) is
probably another source of inspiration since I've been working with that for
quite some time

It is using __fpm__ to create the actual packages.

## Why?

Building operating system packages for Debian/Ubuntu and RedHat using the
official process and tools is pretty annoying if you just want some custom
packages. Jordan's [fpm](https://github.com/jordansissel/fpm) removes the
biggest hurdle by providing a simple command line tool to build packages
for different operating systems.

Before you can use __fpm__ to create the package, you have to build the software,
though. In the past I've been using some shell scripts and Makefiles to
automate this task.

Then I discovered Aman's [brew2deb](https://github.com/tmm1/brew2deb) which is
actually [homebrew](https://github.com/mxcl/homebrew) with some modifications
to make it work on Linux. (only Debian/Ubuntu for now) Since __homebrew__ was
designed for Mac OS X, I thought it would be nice to have a "native" Linux
tool for the job.

__fpm-cookery__ is my attempt to build such a tool.

## Features

* Download of the source archives. (via __curl(1)__)
* Recipes to describe and execute the software build.
  (e.g. configure, make, make install)
* Sandboxed builds.
* Package creation via __fpm__.
* Standalone recipe trees/books/you name it. No need to put the recipes into
  the __fpm-cookery__ source tree.
* Can build [Omnibus](http://wiki.opscode.com/display/chef/Omnibus+Information)
  style packages (allows you to embed many builds into the same package - 
  used by the Opscode folks to build an embedded Ruby and the gems for Chef into
  a single package; also the [Sensu](https://github.com/sensu/sensu) guys do something similar.)

## Upcoming Features

* Recipe validation.
* More source types. (hg, bzr, ...)
* Progress output and logging.
* Extend recipe features and build/install helpers.
* Configuration file. (for stuff like vendor and maintainer)
* Options for the `fpm-cook` command.
* Manpage for the `fpm-cook` command.

## Getting Started

__fpm-cookery__ is available as a gem.

	$ gem install fpm-cookery

Create a recipe directory or change into an existing recipe tree.

    $ cd recipes/redis
    $ fpm-cook clean
    $ fpm-cook

You can install the development dependencies with `bundle install` and run
the included test suite with `rake test`.

## Status

It can build the included `recipes/redis/recipe.rb` and
`recipes/nodejs/recipe.rb` recipes. (both imported from __brew2deb__)
See __CAVEATS__ for an incomplete list of missing stuff.

## Example Recipe

The following is an example recipe. I have some more in my recipe collection
[over here](https://github.com/bernd/fpm-recipes).

```ruby
    class Redis < FPM::Cookery::Recipe
      homepage 'http://redis.io'
      source   'http://redis.googlecode.com/files/redis-2.2.5.tar.gz'
      md5      'fe6395bbd2cadc45f4f20f6bbe05ed09'

      name     'redis-server'
      version  '2.2.5'
      revision '1'

      description 'An advanced key-value store.'

      conflicts 'redis-server'

      config_files '/etc/redis/redis.conf'

      def build
        make

        inline_replace 'redis.conf' do |s|
          s.gsub! 'daemonize no', 'daemonize yes'
        end
      end

      def install
        # make :install, 'DESTDIR' => destdir

        var('lib/redis').mkdir

        %w(run log/redis).each {|p| var(p).mkdir }

        bin.install ['src/redis-server', 'src/redis-cli']

        etc('redis').install 'redis.conf'
        etc('init.d').install 'redis-server.init.d' => 'redis-server'
      end
    end
```

## CAVEATS

* At the moment, there's only a small subset of the __homebrew__ DSL implemented.
* No recipe documentation and API documentation yet.
* No recipe validation yet.
* No dependency validation yet.
* Pretty new and not well tested.

## Credits

__fpm-cookery__ borrows lots of __ideas__ and also __code__ from the
[homebrew](https://github.com/mxcl/homebrew) and
[brew2deb](https://github.com/tmm1/brew2deb) projects.

## License

The BSD 2-Clause License - See [LICENSE](LICENSE) for details

## How To Contribute

* I'd love to hear if you like it, hate it, use it and if you have suggestions
  and/or problems.
* Send pull requests. (hugs for topic branches and tests)
* Have fun!
