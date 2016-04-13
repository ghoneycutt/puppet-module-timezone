# == Class: timezone
#
# Manage system's default timezone setting.
#
class timezone (
  $timezone    = 'UTC',
  $hwclock_utc = true,
  $arc         = undef,
  $srm         = undef,
) {

  if type3x($hwclock_utc) == 'string' {
    $hwclock_utc_real = str2bool($hwclock_utc)
  } else {
    $hwclock_utc_real = $hwclock_utc
  }
  validate_bool($hwclock_utc)

  $tzdata = "/usr/share/zoneinfo/${timezone}"
  validate_absolute_path($tzdata)

  if $arc != undef {
    if type3x($arc) == 'string' {
      $arc_real = str2bool($arc)
    } else {
      $arc_real = $arc
    }
    validate_bool($arc_real)
  }

  if $srm != undef {
    if type3x($srm) == 'string' {
      $srm_real = str2bool($srm)
    } else {
      $srm_real = $srm
    }
    validate_bool($srm_real)
  }

  case $::osfamily {
    'RedHat': {

      if versioncmp("${::operatingsystemmajrelease}", '7') != 0 { # lint:ignore:only_variable_string
        file { '/etc/sysconfig/clock':
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('timezone/clock.erb'),
        }
      }

      file { '/etc/localtime':
        ensure => link,
        target => $tzdata,
      }
    }
    'Debian': {

      file { '/etc/timezone':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${timezone}\n",
      }
      file { '/etc/localtime':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => file($tzdata),
      }
    }
    default: {
      fail("timezone supports osfamily RedHat and Debian. Detected osfamily is <${::osfamily}>.")
    }
  }
}
