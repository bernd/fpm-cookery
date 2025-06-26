# v0.37.0 (2023-04-04)
* Add `osfamily` fact and choose package target based on it. (FooBarQuaxx / #216)
* Install Sphinx toolchain for GitHub Action workflow. (FooBarQuaxx / #217)
* Add support for Ruby 3.2. (FooBarQuaxx / #218, bernd / #219)

# v0.36.0 (2022-07-13)
* Add Dockerfile for Ubuntu 18.04.
* Allow newer versions of Puppet (gmathes / #211)
* Fix compatibility issues with newer Ruby and newer dependencies. (#214)
* Add Ruby versions up to 3.1 to GitHub Action workflow.
* Switch default branch to `main`.

# v0.35.1 (2019-12-18)
* Fix default Docker image name

# v0.35.0 (2019-12-18)
* Add support for building packages inside Docker containers.

# v0.34.0 (2019-06-01)
* Use factor defaults for `platform` and `target` values. (FooBarQuaxx / #189)
* Add `:username` and `:password` parameters to the SVN source handler. (tomeon / #191)
* Add `Recipe#extract` method to allow custom extraction logic.
* Fix tmux location in getting started guide. (cvhbsk / #195)
* Use RPM target for SLES platform. (FooBarQuaxx / #198)
* Add `targets` block for target specific setting in recipe. (FooBarQuaxx / #199)
* Ensure `:noop` sources are always treated as fetchable. (tomeon / #200)
* Allow usage of newer puppet versions. (lukasz-e / #201)
* Add sha512 checksum support. (b00ga / #202)
* Remove duplicate require. (FooBarQuaxx / #204)
* Automatically gunzip gzipped patch files. (davewongillies / #208)
* Add a golang util. (davewongillies / #209)

# v0.33.0 (2017-07-09)
* Hiera lookups of recipe data from templated YAML files. (BaxterStockman / #150)
* Travis-CI build matrix improvements. (thedrow / #155)
* Expose `lsbcodename` fact. (thedrow / #158)
* Improved build cookie generator. (BaxterStockman / #157)
* Improved facter usage. (BaxterStockman / #167)
* Alpine (apk) package support. (lloydpick / #162)
* Fix typos and missing tests. (lloydpick / #163)
* Add `inspect` command. (BaxterStockman / #165)
* json dependency fix to work with older Rubies. (BaxterStockman / #166)
* Bug fix when using local directory sources. (#164)
* Make vendor delimiter configurable. (#169)
* Ensure consistend extracted source value from all source handlers. (#170)
* Add default package version and guard against nil/empty versions. (BaxterStockman / #176)
* Documenting the use of Hiera in recipes. (BaxterStockman / #184)
* Ruby pre-2.0 compatibility fix. (BaxterStockman / #183)
* Add "safe\_yaml" dependency. (davewongillies / #186, #154)
* Add `rpm_dist` method. (sfzylad / #190)

# v0.32.0 (2016-06-14)
* Add `sourcedir` accessor that holds the path to the extracted source. (#132)
* Add support for DirRecipe and Directory Handler. (cas-ei / #147)
* Extend virtualenv support. (MrPrimate / #146)
* Don't dereference symlinks in 'install'. (phyber / #143)
* Add support for OracleLinux. (#148)
* Initialize submodules after sha/tag/branch has been set. (#144)
* Fix configure arguments for list of strings.


# v0.31.0 (2015-11-07)
* Add support for .tar archives. (devkid / #132)
* Add support for virtualenv recipes. (skoenig/zalando / #137)

# v0.30.1 (2015-09-17)
* Do not extract the source again if it has been extraced in a previous run. (#100)
* Allow passing a `Path` object to the `Path#/` method. (#127)

# v0.30.0 (2015-09-10)
* Add more lifecylce hooks:
  * `before_package_create`
  * `after_package_create`
  * `before_source_download`
  * `after_source_download`
  * `before_source_extraction`
  * `after_source_extraction`
  * `before_build`
  * `after_build`
  * `before_install`
  * `after_install`
* Remove some duplication in dependency handling. (glensc / #114)
* Add `:externals` option to SVN source handler. (glensc / #117)
* Use heredoc when calling hook script in fpm-cookery recipe. (glensc / #121)
* Add `sh()` method as an alias for `safesystem()`.
* Add `install-build-deps` CLI command to install all build dependencies. (cas-ei / #126)
* Fix no-deps CLI flags for omnibus style builds. (cas-ei / #124 / #125)

# v0.29.0 (2015-07-25)
* Start documentation at https://fpm-cookery.readthedocs.org/.
  The documentation is now included in the source code (`docs/` directory) and
  is written in sphinx/rst.
* Add lifecycle hooks to the recipe class. (#113)
  __WARNING__: This is an experimental feature and the hook names might change!
* Add `extraced_source` attribute to the recipe class. (#112)

# v0.28.0 (2015-07-10)
* Add :extract option to git source handler.
  Using ":extract => :clone" with a :git source handler will clone the
  repository into the build directory.
* Ignore more relative dependencies in dependency inspector. (sewhyte / #111)
* Add support for extracting tar.xz files. (djhaskin987 / #109)

# v0.27.0 (2015-04-02)
* Make default prefix configurable. (#104)
* Unbreak running on Ruby 2.2. (#105)
* Fix Puppet dependecy. (#105)

# v0.26.1 (2015-02-22)
* Revert "Avoid using git ls-files in gemspec".

# v0.26.0 (2015-02-22)
* Use FPM exclude code. (#102)
* Add `osrelease` and `osmajorrelease` facts. (#98)
* Avoid using `git ls-files` in gemspec. (beddari / #96)

# v0.25.0 (2014-08-03)
* Add `environment` method to recipe to handle environment settings.
* Allow newer FPM versions than 1.1.
* Unbreak `configure` call without arguments on Ruby 1.8. (#92)
* Basic Scientific Linux support. (jjuarez / #93)
* Update internal recipes. (smasset / #89)

# v0.24.0 (2014-06-03)
* Add amazon linux to the list of RPM-based distros. (skottler / #88)
* Add support for PEAR packages. (mlafeldt / #85)
* Add support for CPAN packages. (mlafeldt / #87)

# v0.23.0 (2014-05-29)
* Add `--skip-package` command line flag. (#86)

# v0.22.0 (2014-05-26)
* Add support to set arbitrary fpm attributes via `fpm_attributes`.
  (unakatsuo / #75, #80)
* Require fpm `~> 1.1.0`. (ryansch / #84)

# v0.21.0 (2014-04-07)
* Unbreak rpm packages by reverting the `%files` change from #67.
* Remove default revision. (smasset / #76)
  __WARNING__: This changes the default package names and metadata!
* Add support for python/pypi packages. (Mic92 / #73, smasset / #78)

# v0.20.1 (2014-03-14)
* Unbreak omnibus and chain packagers. (#69)

# v0.20.0 (2014-03-07)
* Add `--tmp-root` command line option.
* Add `--pkg-dir` command line option.
* Add `--cache-dir` command line option.
* Fix `%files` section in rpms. (unakatsuo / #67)

# v0.19.0 (2014-03-03)
* Correctly set version, iteration and vendor on the FPM object.
  __WARNING__: This changes the default package names!

# v0.18.0 (2014-03-01)
* Do not set a default value for the vendor attribute.
  __WARNING__: This changes the default package names!
* Change package name computation regarding version, revision and vendor.
  __WARNING__: This changes the default package names!
* Start default revision at 1.
* Unbreak omnibus packaging. (#64)
* Add support for npm recipes. (bracki / #65)

# v0.17.1 (2014-02-07)
* Unbreak deb package building.

# v0.17.0 (2014-02-01)
* Update fpm dependency to 1.0.0. (joschi / #62)
* Add `-q` command line option to disable progress bars. (#58)
* Add `directories` recipe attribute. (#53)
* Add `autogen` build helper. (sepulworld/autogen-support / #54)
* Add `root_prefix` and `root` path helper. (sepulworld/set-root-prefix / #52)
* Support recursive omnibus recipes dependencies. (avishai-ish-shalom / #49)

# v0.16.2 (2013-10-19)
* Add support for submodules in git provider. (narkisr / #50)
* Set a default maintainer.
* Fix problems with setting epoch. (#51)

# v0.16.1 (2013-09-26)
* Unbreak package building with broken symlinks.
* Do not fail if git is not installed.

# v0.16.0 (2013-09-21)
* Chain packager. (smasset)
* Add show-depends CLI option. (unakatsuo)
* Add fpm-cookery chain packager gem recipes. (smasset)
* Compatibility fixes for the latest FPM releases. (skiold)
* Fix problems with tar files that contain no directories. (narkisr)
* New CLI options parsing backend. (using clamp)

# v0.15.0 (2013-06-13)
* Add --no-deps option to disable dependency checks.

# v0.14.1 (2013-06-12)
* Handle private GitHub URLs. (aussielunix)
* Fix dependencies in gemspec.

# v0.14.0 (2013-05-31)
* Install dependencies via Puppet. (andytinycat)
* Add install-deps action to install dependencies. (andytinycat)
* Fix log message. (ryansch)
* Add a `patch` helper method to apply patches. (piavlo)
* Support for [Omnibus](http://wiki.opscode.com/display/chef/Omnibus+Information)-style
  packaging. (andytinycat)
* Add recipe to build a fat (omnibus-style) package for fpm-cookery.
* Add `:args` option for the curl handler. (torrancew)
* Add `-V` command line option to show fpm-cookery and fpm versions.

# v0.13.0 (2013-01-28)
* Make local file source behave like the remote url source. (#14)

# v0.12.0 (2013-01-28)
* Copy source files with no or unknown file extension to
  the source dir. (smasset)
* Set deb\_user and deb\_group attributes to root.
* Ensure passing the vendor attribute to fpm. (aussielunix)
* Unbreak logging with the latest fpm.

# v0.11.0 (2012-08-20)
* Add source handler to handle local source directories via file:// urls.

# v0.10.0 (2012-08-12)
* Add support for shar and bin files to curl source handler. (brandonmartin)
* Support an optional basename parameter for the `install` helper.
* Deprecate public usage of the `install_p` helper.
* Add license option to the recipe class.

# v0.9.0 (2012-07-21)
* Allow architecture specific settings via the `architectures` method.
* Unbreak RPM creation on RHEL5. (brandonmartin)

# v0.8.0 (2012-05-23)
* Add /opt path helper.
* Use the new fpm API. (requires at least fpm-0.4.x)
* Show the fpm log output via cabin.
* Skip git fetch if the specified sha or tag exists.

# v0.7.0 (2011-11-26)
* Add hg (mercurial) source handler.
* Fix tags fetchting for the git source handler.

# v0.6.0 (2011-11-19)
* Add a logging/output system.
* Improve extracted source detection for the curl and svn source handler.
* Allow absolute paths for pre/post scripts.

# v0.5.0 (2011-11-05)
* Add git source handler.

# v0.4.0 (2011-10-28)
* Add svn source handler. (lusis)
* Framework for alternate source handlers. (lusis)
* Add .zip support to the curl source handler.
* Detect package target based on the platform.
* Allow platform specific options. (like dependencies) (lusis)
* Add platform (operating system) detection. (lusis)

# v0.3.0 (2011-10-25)
* Select vendor string delimiter based on the package target. (lusis)
* Add pre/post install/uninstall script support. (lusis)

# v0.2.0 (2011-10-22)
* Add flag for package target. (deb, rpm) (jordansissel)
* Improve recipe detection. (jordansissel)

# v0.1.0 (2011-10-18)
* Add `with_trueprefix` path helper.
* Add and enable source integrity check.

# v0.0.1 (2011-10-11)
* Initial gem release.
