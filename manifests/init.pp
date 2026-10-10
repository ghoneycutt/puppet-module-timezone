# @summary This module manages the system's default timezone setting.
#
# @example Declaring the class
#   include timezone
#
# @param timezone
#   The systems default timezone, e.g. 'UTC' or 'Europe/Berlin'. See
#   `/usr/share/zoneinfo` for available values.
#
class timezone (
  String[1] $timezone = 'UTC',
) {

  $tzdata = "/usr/share/zoneinfo/${timezone}"

  file { '/etc/localtime':
    ensure => link,
    target => $tzdata,
  }

  # Debian retired /etc/timezone in Debian 13 (tzdata no longer creates or
  # updates it; the /etc/localtime symlink is the only mechanism). Ubuntu
  # 22.04 and 24.04 still ship and maintain the file; Ubuntu 26.04 follows
  # Debian 13. Remove this block when Ubuntu 24.04 support is dropped.
  if $facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '26.04') < 0 {
    file { '/etc/timezone':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "${timezone}\n",
    }
  }
}
