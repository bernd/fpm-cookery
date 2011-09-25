# fpm-cookery - For building software

A tool for building software packages with
[fpm](https://github.com/jordansissel/fpm).

The [fpm](https://github.com/jordansissel/fpm) project is really nice for
building operating system packages like `.deb` and `.rpm`. But it only helps
you to create the packages and doesn't help you with actually building the
software.

_fpm-cookery_ provides an infrastructure to automatically build software
based on recipes. It's heavily inspired and borrows code from the great
[homebrew](https://github.com/mxcl/homebrew) and
[brew2deb](https://github.com/tmm1/brew2deb) projects.
The [OpenBSD Ports System](http://www.openbsd.org/faq/ports/index.html) is
probably another source of inspiration since I've been working with that for
quite some time

It is using _fpm_ to create the actual packages.

## Why?

Building operating system packages for Debian/Ubuntu and RedHat using the
official process and tools is pretty annoying if you just want some custom
packages. Jordan's [fpm](https://github.com/jordansissel/fpm) removes the
biggest hurdle by providing a simple command line tool to build packages
for different operating systems.

Before you can use _fpm_ to create the package, you have to build the software,
though. In the past I've been using some shell scripts and Makefiles to
automate this task.

Then I discovered Aman's [brew2deb](https://github.com/tmm1/brew2deb) which is
actually [homebrew](https://github.com/mxcl/homebrew) with some modifications
to make it work on Linux. (only Debian/Ubuntu for now) Since _homebrew_ was
designed for Mac OS X, I thought it would be nice to have a "native" Linux
tool for the job.

_fpm-cookery_ is my attempt to build such a tool.

## Features

* Download of the source archives. (via _curl(1)_)
* Recipes to describe and execute the software build.
  (e.g. configure, make, make install)
* Sandboxed builds.
* Package creation via _fpm_.
* Standalone recipe trees/books/you name it. No need to put the recipes into
  the _fpm-cookery_ source tree.

## Upcoming Features

* Apply custom patches.
* Dependency checking.
* Recipe validation.
* Integrity checks for downloaded archives.
* More source types. (git, svn, ...)
* Progress output and logging.
* Extend recipe features and build/install helpers.
* Configuration file. (for stuff like vendor and maintainer)
* Options for the `fpm-cook` command.
* Manpage for the `fpm-cook` command.

## Getting Started

Since there is no gem available yet, you have to clone the repository to
your local machine and run the following to build a recipe.

    $ ruby bin/fpm-cook recipes/redis/recipe.rb clean
    $ ruby bin/fpm-cook recipes/redis/recipe.rb

Or change into the recipe directory.

    $ export PATH="$PWD/bin:$PATH"
    $ cd recipes/redis
    $ fpm-cook clean
    $ fpm-cook

You can run the included test suite with `rake test`. This needs the _rake_
and _minitest_ gems.

## Status

It can build the included `recipes/redis/recipe.rb` and
`recipes/nodejs/recipe.rb` recipes. (both imported from _brew2deb_)
See _CAVEATS_ for an incomplete list of missing stuff.

## Example Recipe

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

* At the moment, there's only a small subset of the _homebrew_ DSL implemented.
* No recipe documentation and API documentation yet.
* No recipe validation yet.
* No dependency validation yet.
* No integrity check of the downloaded archives yet.
* No support for patches yet.
* Only simple source/url types (via curl) for now.
* No real logging output yet.
* No gem on rubygems.org yet.
* Pretty new and not well tested.

## Credits

_fpm-cookery_ borrows lots of _ideas_ and also _code_ from the
[homebrew](https://github.com/mxcl/homebrew) and
[brew2deb](https://github.com/tmm1/brew2deb) projects. Both projects don't
have any licensing information included in their repositories. So licensing
is still an open question for now.

## How To Contribute

* I'd love to hear if you like it, hate it, use it and if you have suggestions
  and/or problems.
* Send pull requests. (hugs for topic branches and tests)
* Have fun!
