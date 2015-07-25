.. fpm-cookery documentation master file, created by
   sphinx-quickstart on Sat Jul 25 11:02:45 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to the fpm-cookery documentation!
=========================================

**Current version:** |version|

fpm-cookery provides an infrastructure to automatically build software based on recipes. It's heavily inspired and borrows code from the great `homebrew <https://github.com/mxcl/homebrew>`_ and `brew2deb <https://github.com/tmm1/brew2deb>`_ projects.

Features
^^^^^^^^

* Source archive download and caching.
* Recipes to describe and execute the software build. (e.g. configure, make, make install)
* Sandboxed builds.
* Package creation via `fpm <https://github.com/jordansissel/fpm>`_.
* Standalone recipe trees/books/you name it. No need to put the recipes into the fpm-cookery source tree.

Documentation Contents
^^^^^^^^^^^^^^^^^^^^^^

.. toctree::
   :maxdepth: 2

   pages/getting-started


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

