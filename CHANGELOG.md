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
