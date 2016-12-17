Using Hiera
===========

`Hiera <http://docs.puppetlabs.com/hiera>`_ is a hierarchical key-value lookup
tool from Puppet Labs that, integrated with fpm-cookery, allows you to improve
your package builds by:

* Separating data from build logic,
* Selectively overriding particular recipe attributes for different platforms,
  software versions, etc., and
* Staying DRY by reusing data via the ``hiera`` and ``scope``
  :ref:`interpolation methods <hiera-interpolation-in-data-files>`.

Configuring Hiera
-----------------

Controlling the Lookup Hierarchy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By default, FPM-Cookery looks for Hiera data files under the ``config``
subdirectory of the directory containing the target recipe. You can override
this through the ``--data-dir`` option to ``fpm-cook``. You can also set the
data file directory via the ``datadir=`` class method while defining the recipe
class:

.. code-block:: ruby

    class FreshRecipe < FPM::Cookery::Recipe
      datadir = "/somewhere/other/than/#{File.dirname(__FILE__)}/config"
    end

.. note::

    Part of the recipe initialization process involves :ref:`automatically
    applying data<hiera-automatic-application-of-hiera-data>` contained in the
    files in the current ``datadir``.  If you change ``datadir`` after the
    ``initialize`` method completes, you must call the ``apply`` method
    manually to reconfigure the recipe according to the files in the the new
    ``datadir``.

When retrieving recipe data, fpm-cookery observes the following hierarchy of
files under ``datadir``, ordered from highest to lowest precedence:

+--------------------------------+--------------------------------------------+
| Path                           | Description                                |
+================================+============================================+
| ``"#{recipe.platform}.yaml"``, | The platform for which the recipe is being |
| ``"#{recipe.platform}.json"``  | built.  Corresponds to Facter's            |
|                                | ``operatingsystem`` fact, except that all  |
|                                | characters are lowercase. For instance, if |
|                                | ``operatingsystem`` is ``ArchLinux``,      |
|                                | ``recipe.platform`` will be ``archlinux``. |
+--------------------------------+--------------------------------------------+
| ``"#{recipe.target}.yaml"``,   | The target package type.  Options span all |
| ``"#{recipe.target}.json"``    | package types that FPM can build,          |
|                                | including include ``rpm``, ``apk``,        |
|                                | ``deb``, ``osxpkg``, and others.           |
+--------------------------------+--------------------------------------------+
| ``"common.yaml"``,             | Intended for configuration data that is    |
| ``"common.json"``              | common to all builds.                      |
+--------------------------------+--------------------------------------------+

You can further influence the lookup hierarchy by setting the environment
variable ``FPM_HIERARCHY``.  The value should be string containing a
colon-separated list of filename stems.  For example::

  $ FPM_HIERARCHY=centos:rhel:el fpm-cook package

prepends ``centos``, ``rhel``, and ``el`` to the search hierarchy, causing
fpm-cookery to attempt load data from ``centos.yaml``, ``rhel.yaml``,
``el.yaml``, and their ``.json`` counterparts.  The final hierarchy is:

* ``"centos.yaml"``
* ``"rhel.yaml"``
* ``"el.yaml"``
* ``"#{recipe.platform}.yaml"``
* ``"#{recipe.target}.yaml"``
* ``"common.yaml"``

Other Settings
^^^^^^^^^^^^^^

You can exercise more fine-grained control by providing the path to a Hiera
configuration file via the ``--hiera-config`` option. See `the Hiera docs
<http://docs.puppetlabs.com/hiera/3.0/configuring.html>`_ for available
configuration file options.

Hiera in Recipes
----------------

Lookups
^^^^^^^

fpm-cookery provides the ``lookup`` class method on all classes that inherit
from ``FPM::Cookery::Recipe``, as well as an instance method of the same name.
``lookup`` takes one mandatory argument: a key to be looked up in the Hiera
data files.  If Hiera locates the key, ``lookup`` returns the corresponding
value; otherwise ``lookup`` returns ``nil``.

Writing Data Files
^^^^^^^^^^^^^^^^^^

See `the Hiera data sources documentation <http://docs.puppetlabs.com/hiera/3.0/data_sources.html>`_
for an overview of Hiera data sources.

.. note::

    Please ensure that your data files use the extensions ``.yaml`` or
    ``.json``, as appropriate -- Hiera ignores files with any other
    extension.

You'll probably find data files most useful for defining recipe attributes.
However, key-value mappings in Hiera data sources need not correspond to recipe
attributes -- you can store any data you like as long as it is valid YAML or
JSON:

.. code-block:: yaml

    name: custom-package
    version: '2.1.6'
    some_arbitrary_data:
      - thing one
      - thing two
      - thing: three
        is_a: hash

*(later on...)*

.. code-block:: ruby

    CustomPackageRecipe.lookup('some_arbitrary_data')
      #=> ['thing one', 'thing two', {'thing' => 'three', 'is_a' => 'hash'}]

.. _hiera-interpolation-in-data-files:

Interpolation in Data Files
'''''''''''''''''''''''''''

Within a data file, the ``%{scope("...")}`` method interpolates values from the
following sources:

* The current recipe class
* ``FPM::Cookery::Facts``
* `Facter <https://puppetlabs.com/facter>`_ facts

The ``%{hiera("...")}`` method interpolates values looked up in the data files
themselves.

Say you are on an ``x86_64`` system, and consider the following YAML data:

.. code-block:: yaml

    name: something-clever
    version: '0.9.0'
    source: 'https://www.sporkforge.net/archive/%{scope("arch")}/%{hiera("name")}-%{hiera("version")}.tar.gz'

``source`` evaluates like so:

.. code-block:: ruby

    SomethingCleverRecipe.lookup('source')
      #=> 'https://www.sporkforge.net/archive/x86_64/something-clever-0.9.0.tar.gz'

.. _hiera-automatic-application-of-hiera-data:

Symbolized Hash Keys
''''''''''''''''''''

Ruby's YAML library automatically converts hash keys prefixed with colons into
symbols.  This is good to know when using Hiera to store data relevant to
methods that expect symbols in their arguments -- for instance, ``source``.

**BAD**:

.. code-block:: yaml

    source:
      - 'git://gogs.myhostname.info/labyrinthm/bowie.git'
      - with: git
        tag: 'v1.1.3'

**GOOD**:

.. code-block:: yaml

    source:
      - 'git://gogs.myhostname.info/labyrinthm/bowie.git'
      - :with: git
        :tag: 'v1.1.3'

Method Signatures and Unpacking Data Structures
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

fpm-cookery tries to Do What You Mean when dealing when loading data from
Hiera, but there are some subtleties relating to method signatures that you
should be aware of.

Methods that expect a single argument are the simplest case -- just provide a
single key-value pair:

.. code-block:: yaml

    name: 'myrecipe'

Methods that expect multiple arguments should be given as a list:

.. code-block:: yaml

    depends:
      - openssl-devel
      - docker-compose

fpm-cookery will automatically unpack the argument list with Ruby's splat
(``*``) operator when invoking the method.

Methods that expect a hash should be given as a series of key-value pairs:

.. code-block:: yaml

    environment:
      LC_ALL: C
      SHELLOPTS: xtrace
      PAGER: cat

fpm-cookery will *merge* these pairs into whatever data is already assigned as
the value of the attribute, rather than replacing it.

Some methods expect a heterogeneous list of arguments, ``source`` being the
most important of these.  If you want to pass options to ``source`` or other
such methods, use the following technique:

.. code-block:: yaml

    source:
      - 'https://my.subversion-server.net/trunk'
      - :revision: 92834
        :externals: false

This translates to a Ruby ``Array``:

.. code-block:: ruby

    ['https://my.subversion-server.net/trunk', {:revision => 92834, :externals => false}]

For simple sources that consist only of a URL, you can do:

.. code-block:: yaml

    source: 'git://our.internal-git.com/foo/bar.git'

Automatic Application of Hiera Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As part of the recipe initialization process, fpm-cookery calls ``lookup`` to
retrieve any Hiera-defined values corresponding to recipe attribute names such
as ``name``, ``version``, and ``source``.  If Hiera can locate the key,
fpm-cookery automatically sets the relevant attribute to the retrieved value.

Attributes defined in Hiera data files take precedence over
attributes defined in ``recipe.rb``:

.. code-block:: yaml

    --- # common.yaml
    source: https://www.repourl.org/source/neato-0.2.4-7.tar.bz2

.. code-block:: ruby

    # recipe.rb
    class NeatoRecipe < FPM::Cookery::Recipe
      source 'https://www.repourl.org/source/nightly/neato-nightly.tar.gz'
    end

This results in:

.. code-block:: ruby

    NeatoRecipe.source #=> https://www.repourl.org/source/neato-0.2.4-7.tar.bz2

Examples
--------

See the `Redis recipe
<https://github.com/bernd/fpm-cookery/tree/master/recipes/redis>`_ for an
example of fpm-cookery and Hiera in action.
