Getting Started
===============

This page helps you to get started with the fpm-cookery tool and guides you
through the installation and the creation of a simple recipe to build your
first package.

You will create a package for the `tmux <http://tmux.sourceforge.net/>`_ program.

Prerequisites
-------------

The following instructions have been tested with an Ubuntu 12.04 Linux system.
It might work on other versions or other Linux systems but that cannot be
guaranteed. Please use something like `Vagrant <http://www.vagrantup.com/>`_ to
create an Ubuntu 12.04 VM if you do not have one at hand.

Installation
------------

Rubygems
^^^^^^^^

fpm-cookery is written in Ruby. Before we can actually install the rubygem, you
have to install a Ruby interpreter and some build tools.
Execute the following to install the required packages::

  $ sudo apt-get install ruby1.9.1 ruby1.9.1-dev build-essential curl

Ruby 1.9 includes the ``gem`` program to install rubygems::

  $ sudo gem install fpm-cookery

This installs the fpm-cookery rubygem and its dependencies. At the end you
should see something like "Successfully installed fpm-cookery-|version|".

Your fpm-cookery installation is ready to build some packages now!

OS Package
^^^^^^^^^^

We are planning to provide a packaged version for different operating systems.
Please use the Rubygems installation method above in the meantime.

The Recipe
----------

The recipe is a Ruby file that contains a simple class which acts as a DSL
to set the attributes of a package (like name and version) and to describe
the build and installation process of a package.

You might want to create some folders to organize your recipes::

  $ mkdir recipes
  $ mkdir recipes/tmux
  $ cd recipes/tmux
  $ touch recipe.rb

The last command creates an empty recipe file. See the following snippet for
the complete recipe to build a tmux package. We will go through each step
afterwards. Use your text editor to add the code to the ``recipe.rb`` file.

.. code-block:: ruby

  class Tmux < FPM::Cookery::Recipe
    description 'terminal multiplexer'

    name     'tmux'
    version  '1.9a'
    homepage 'http://tmux.sourceforce.net/'
    source   'http://freefr.dl.sourceforge.net/project/tmux/tmux/tmux-1.9/tmux-1.9a.tar.gz'

    build_depends 'libevent-dev', 'libncurses5-dev'
    depends       'libevent-2.0-5'

    def build
      configure :prefix => prefix
      make
    end

    def install
      make :install, 'DESTDIR' => destdir
    end
  end

Example Workflow
----------------

The following commands require the ``recipe.rb`` recipe file created above.

.. code-block:: none

  $ fpm-cook
  ===> Starting package creation for tmux-1.9a (ubuntu, deb)
  ===>
  ===> Verifying build_depends and depends with Puppet
  ===> Verifying package: libevent-dev
  ===> Verifying package: libevent-2.0-5
  ===> Missing/wrong version packages: libevent-dev
  ERROR: Not running as root; please run 'sudo fpm-cook install-deps' to install dependencies.

.. code-block:: none

  $ sudo fpm-cook install-deps
  ===> Verifying build_depends and depends with Puppet
  ===> Verifying package: libevent-dev
  ===> Verifying package: libevent-2.0-5
  ===> Missing/wrong version packages: libevent-dev
  ===> Running as root; installing missing/wrong version build_depends and depends with Puppet
  ===> Installing package: libevent-dev
  ===> ensure changed 'purged' to 'present'
  ===> All dependencies installed!

.. code-block:: none

  $ fpm-cook
  ===> Starting package creation for tmux-1.9a (ubuntu, deb)
  ===>
  ===> Verifying build_depends and depends with Puppet
  ===> Verifying package: libevent-dev
  ===> Verifying package: libncurses5-dev
  ===> Verifying package: libevent-2.0-5
  ===> All build_depends and depends packages installed
  ===> Fetching source:
  ######################################################################## 100.0%
  ===> Building in /home/vagrant/recipes/tmux/tmp-build/tmux-1.9a
  checking for a BSD-compatible install... /usr/bin/install -c
  checking whether build environment is sane... yes

  [lots of output removed]

  make[1]: Nothing to be done for `install-data-am'.
  make[1]: Leaving directory `/home/vagrant/recipes/tmux/tmp-build/tmux-1.9a'
  ===> [FPM] Converting dir to deb {}
  ===> [FPM] No deb_installed_size set, calculating now. {}
  ===> [FPM] Reading template {"path":"/var/lib/gems/1.9.1/gems/fpm-1.0.2/templates/deb.erb"}
  ===> [FPM] Creating {"path":"/tmp/package-deb-build20140308-7998-1v6uqm5/control.tar.gz","from":"/tmp/package-deb-build20140308-7998-1v6uqm5/control"}
  ===> [FPM] Created deb package {"path":"tmux_1.9a-1_amd64.deb"}
  ===> Created package: /home/vagrant/recipes/tmux/pkg/tmux_1.9a-1_amd64.deb

.. code-block:: none

  .
  |-- cache
  |   `-- tmux-1.9a.tar.gz
  |-- pkg
  |   `-- tmux_1.9a-1_amd64.deb
  |-- recipe.rb
  |-- tmp-build
  |   `-- tmux-1.9a
  `-- tmp-dest
      `-- usr

.. code-block:: none

  $ dpkg -c pkg/tmux_1.9a-1_amd64.deb
  drwxrwxr-x 0/0               0 2014-03-08 01:26 ./
  drwxrwxr-x 0/0               0 2014-03-08 01:26 ./usr/
  drwxrwxr-x 0/0               0 2014-03-08 01:26 ./usr/share/
  drwxrwxr-x 0/0               0 2014-03-08 01:26 ./usr/share/man/
  drwxrwxr-x 0/0               0 2014-03-08 01:26 ./usr/share/man/man1/
  -rw-r--r-- 0/0           93888 2014-03-08 01:26 ./usr/share/man/man1/tmux.1
  drwxrwxr-x 0/0               0 2014-03-08 01:26 ./usr/bin/
  -rwxr-xr-x 0/0          491016 2014-03-08 01:26 ./usr/bin/tmux

.. code-block:: none

  $ dpkg -I pkg/tmux_1.9a-1_amd64.deb
   new debian package, version 2.0.
   size 235488 bytes: control archive= 437 bytes.
       260 bytes,    12 lines      control
       105 bytes,     2 lines      md5sums
   Package: tmux
   Version: 1.9a-1
   License: unknown
   Vendor:
   Architecture: amd64
   Maintainer: <vagrant@ubuntu1204>
   Installed-Size: 571
   Depends: libevent-2.0-5
   Section: optional
   Priority: extra
   Homepage: http://tmux.sourceforce.net/
   Description: terminal multiplexer
