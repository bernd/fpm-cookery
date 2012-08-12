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
