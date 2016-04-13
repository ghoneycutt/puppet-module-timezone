# puppet-module-timezone
===

[![Build Status](https://api.travis-ci.org/ghoneycutt/puppet-module-timezone.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-timezone)

Manage system time zone.

===

# Compatibility
---------------
This module has been tested to work on the following systems with Puppet v3
(with and without the future parser) and v4 with Ruby versions 1.8.7 (Puppet v3
only), 1.9.3, 2.0.0 and 2.1.0.

* EL 5
* EL 6
* EL 7
* Debian

===

# Parameters

timezone
--------
The systems default timezone, e.g. 'UTC' or 'Europe/Berlin'.
See /usr/share/zoneinfo for available values.

- *Default*: 'UTC'

hwclock_utc
-----------
Boolean value indicating if the system's hardware clock is
UTC (true) or localtime (false). This value is only
used on osfamily RedHat.

- *Default*: true

arc
---
Boolean value. False indicates that the normal UNIX epoch is in use. Used by EL 5.

- *Default*: undef

srm
---
Boolean value. False indicates that the normal UNIX epoch is in use. Used by EL 5.

- *Default*: undef

===

# Contributors

Niklas Grossmann <ngrossmann@gmx.net>
Garrett Honeycutt <gh@learnpuppet.com>
