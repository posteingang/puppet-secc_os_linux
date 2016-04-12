# hardening mountpoints
class secc_os_linux::mounts (
  $secure_mountpoint_tmp,
  $secure_mountpoint_var,
  $secure_mountpoint_var_tmp,
  $secure_mountpoint_home,
  $test_kitchen_run,
){

  # noexec on /tmp prevents test-kitchen :/
  if ( $test_kitchen_run ) {
    $tmp_mount_options = 'defaults,nodev,nosuid'
  } else {
    $tmp_mount_options = 'defaults,noexec,nodev,nosuid'
  }


  if ( $secure_mountpoint_tmp ) {
    mount { '/tmp':
      ensure  => 'mounted',
      options => $tmp_mount_options,
      target  => '/etc/fstab',
      pass    => '2',
    }
  }

  if ( $secure_mountpoint_var ) {
    mount { '/var':
      ensure  => 'mounted',
      options => 'defaults,noexec,nodev,nosuid',
      target  => '/etc/fstab',
      pass    => '2',
    }
  }

  if ( $secure_mountpoint_home ) {
    mount { '/home':
      ensure  => 'mounted',
      options => 'defaults,nodev',
      target  => '/etc/fstab',
      pass    => '2',
    }
  }

  if ( $secure_mountpoint_var_tmp ) {
    mount {'/var/tmp':
      ensure  => 'mounted',
      device  => '/tmp',
      fstype  => 'none',
      options => 'bind',
      pass    => '0',
    }
  }

}
