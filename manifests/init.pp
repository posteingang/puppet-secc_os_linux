# SecC Linux OS Hardening
class secc_os_linux (
  $ext_tftp_server_package_status       = absent,
  $ext_xinetd_package_status            = absent,
  $ext_remove_users                     = [ 'ftp', 'games', 'gopher', 'uucp' ],
  $ext_remove_groups                    = [ 'ftp', 'games', 'gopher', 'uucp', 'video', 'tape' ],
  $ext_remove_packages                  = [ 'abrtd', 'autofs', 'avahi-daemon', 'cpuspeed', 'ftp', 'inetd', 'kdump', 'rlogin', 'rsh-server', 'telnet-server', 'ypserv', 'ypbind', 'aic94xx-firmware', 'atmel-firmware', 'adaptec-firmware', 'bfa-firmware', 'brocade-firmware', 'icom-firmware', 'ipw-firmware', 'ipw2100-firmware', 'ipw2200-firmware', 'ivtv-firmware', 'iwl100-firmware', 'iwl105-firmware', 'iwl135-firmware', 'iwl1000-firmware', 'iwl2000-firmware', 'iwl2030-firmware', 'iwl3160-firmware', 'iwl3945-firmware', 'iwl4965-firmware', 'iwl5000-firmware', 'iwl5150-firmware', 'iwl6000-firmware', 'iwl6000g2a-firmware', 'iwl6000g2b-firmware', 'iwl6050-firmware', 'iwl7260-firmware', 'iwl7265-firmware', 'libertas-sd8686-firmware', 'libertas-sd8787-firmware', 'libertas-usb8388-firmware', 'mpt-firmware', 'ql2100-firmware', 'ql2200-firmware', 'ql23xx-firmware', 'ql2400-firmware', 'ql2500-firmware', 'rt61pci-firmware', 'rt73usb-firmware', 'xorg-x11-drv-ati-firmware', 'zd1211-firmware'],
  $ext_test_kitchen_run                 = false,
  $ext_rootsh_enabled                   = true,
  $ext_bash_ps1                         = 'PS1="\[$(tput bold)\]\[$(tput setaf 3)\]\\u\[$(tput setaf 4)\]@\[$(tput setaf 2)\]\\h\[$(tput setaf 4)\]:\[$(tput setaf 7)\]\\w\[$(tput setaf 4)\]\\$ \[$(tput sgr0)\]"',
  $ext_stop_and_disable_services        = [ 'abrtd', 'acpid', 'anacron', 'cups', 'dhcpd', 'network-remotefs', 'haldaemon', 'lm_sensors', 'mdmonitor', 'netconsole', 'netfs', 'nfs', 'ntpdate', 'oddjobd', 'portmap', 'portreserve', 'qpidd', 'quota_nld', 'rdisc', 'rhnsd', 'rhsmcertd', 'saslauthd', 'sendmail', 'smartd', 'sysstat', 'vsftpd', 'wpa_supplicant' ],
  $ext_stop_services                    = [ 'nfslock', 'rpcgssd', 'rpcidmapd', 'rpcsvcgssd' ],
  $ext_rsyslog_setting_var_log_messages = '*.info;mail.none;authpriv.none;cron.none;local5.none;local6.none',
  $ext_logrotate_enabled                = true,
  $ext_logrotate_time                   = 'weekly',
  $ext_logrotate_rotate                 = '13',
  $ext_logrotate_missingok              = false,
  $ext_logrotate_dateext                = false,
  $ext_logrotate_compress               = false,
  $ext_enable_ipv4_forwarding           = false,
  $ext_enable_ipv6                      = false,
  $ext_enable_ipv6_forwarding           = false,
  $ext_arp_restricted                   = true,
  $ext_enable_stack_protection          = true,
  $ext_rsyslog_manage_service           = true,
  $ext_disable_kernel_modules           = [ 'usb-storage', 'firewire-core', 'firewire-ohci', 'cramfs', 'freevxfs', 'jffs2', 'hfs', 'hfsplus', 'squashfs', 'udf', 'isdn' ],
  $ext_mount_options_tmp                = 'defaults,noexec,nodev,nosuid',
  $ext_mount_options_var                = 'defaults,nodev,nosuid',
  $ext_mount_options_var_tmp            = 'bind',
  $ext_mount_options_home               = 'defaults,nodev',
  $ext_secure_mountpoint_tmp            = true,
  $ext_secure_mountpoint_var            = true,
  $ext_secure_mountpoint_var_tmp        = true,
  $ext_secure_mountpoint_home           = true,
  $ext_profile_umask                    = '027',
  $ext_manage_passwords                 = true,
){

  $tftp_server_package_status       = hiera("${module_name}::tftp_server_package_status", $ext_tftp_server_package_status)
  $xinetd_package_status            = hiera("${module_name}::xinetd_package_status", $ext_xinetd_package_status)
  $remove_packages                  = hiera("${module_name}::remove_packages", $ext_remove_packages)
  $remove_users                     = hiera("${module_name}::remove_users", $ext_remove_users)
  $remove_groups                    = hiera("${module_name}::remove_groups", $ext_remove_groups)
  $rootsh_enabled                   = hiera("${module_name}::rootsh_enabled", $ext_rootsh_enabled)
  $bash_ps1                         = hiera("${module_name}::bash_ps1", $ext_bash_ps1)
  $stop_and_disable_services        = hiera("${module_name}::stop_and_disable_services", $ext_stop_and_disable_services)
  $stop_services                    = hiera("${module_name}::stop_services", $ext_stop_services)
  $rsyslog_setting_var_log_messages = hiera("${module_name}::rsyslog_setting_var_log_messages", $ext_rsyslog_setting_var_log_messages)
  $logrotate_enabled                = hiera("${module_name}::logrotate_enabled", $ext_logrotate_enabled)
  $enable_ipv4_forwarding           = hiera("${module_name}::enable_ipv4_forwarding", $ext_enable_ipv4_forwarding)
  $enable_ipv6                      = hiera("${module_name}::enable_ipv6_forwarding", $ext_enable_ipv6)
  $enable_ipv6_forwarding           = hiera("${module_name}::enable_ipv6_forwarding", $ext_enable_ipv6_forwarding)
  $arp_restricted                   = hiera("${module_name}::arp_restricted", $ext_arp_restricted)
  $enable_stack_protection          = hiera("${module_name}::enable_stack_protection", $ext_enable_stack_protection)
  $rsyslog_manage_service           = hiera("${module_name}::rsyslog_manage_service", $ext_rsyslog_manage_service)
  $disable_kernel_modules           = hiera("${module_name}::disable_kernel_modules", $ext_disable_kernel_modules)
  $mount_options_tmp                = hiera("${module_name}::mount_options_tmp", $ext_mount_options_tmp)
  $mount_options_var                = hiera("${module_name}::mount_options_var", $ext_mount_options_var)
  $mount_options_var_tmp            = hiera("${module_name}::mount_options_var_tmp", $ext_mount_options_var_tmp)
  $mount_options_home               = hiera("${module_name}::mount_options_home", $ext_mount_options_home)
  $secure_mountpoint_tmp            = hiera("${module_name}::secure_mountpoint_tmp", $ext_secure_mountpoint_tmp)
  $secure_mountpoint_var            = hiera("${module_name}::secure_mountpoint_var", $ext_secure_mountpoint_var)
  $secure_mountpoint_var_tmp        = hiera("${module_name}::secure_mountpoint_var_tmp", $ext_secure_mountpoint_var_tmp)
  $secure_mountpoint_home           = hiera("${module_name}::secure_mountpoint_var", $ext_secure_mountpoint_home)
  $profile_umask                    = hiera("${module_name}::profile_umask", $ext_profile_umask)
  $manage_passwords                 = hiera("${module_name}::manage_passwords", $ext_manage_passwords)

  include secc_os_linux::audit

  # disabled while rolling out to pilots
  # include secc_os_linux::arpwatch

  include secc_os_linux::inputrc

  class {'secc_os_linux::kernel':
    enable_ipv4_forwarding  => $enable_ipv4_forwarding,
    enable_ipv6             => $enable_ipv6,
    enable_ipv6_forwarding  => $enable_ipv6_forwarding,
    arp_restricted          => $arp_restricted,
    enable_stack_protection => $enable_stack_protection,
  }

  include secc_os_linux::login_defs

  class { 'secc_os_linux::modules':
    disable_kernel_modules    => $disable_kernel_modules,
  }

  contain secc_os_linux::mounts

  contain secc_os_linux::password

  class { 'secc_os_linux::packages':
    tftp_server_package_status => $tftp_server_package_status,
    xinetd_package_status      => $xinetd_package_status,
    remove_packages            => $remove_packages,
  }

  class { 'secc_os_linux::profile':
    profile_umask => $profile_umask,
  }

  class { 'secc_os_linux::rootsh':
    rootsh_enabled => $rootsh_enabled,
    bash_ps1       => $bash_ps1,
  }

  class { 'secc_os_linux::services':
    stop_and_disable_services => $stop_and_disable_services,
    stop_services             => $stop_services,
  }

  class { 'secc_os_linux::syslog':
    rsyslog_setting_var_log_messages => $rsyslog_setting_var_log_messages,
    rsyslog_manage_service           => $rsyslog_manage_service,
  }

  class { 'secc_os_linux::users_group':
    remove_users  => $remove_users,
    remove_groups => $remove_groups,
  }

  class { 'secc_os_linux::logrotate':
    logrotate_enabled   => $ext_logrotate_enabled,
    logrotate_time      => $ext_logrotate_time,
    logrotate_rotate    => $ext_logrotate_rotate,
    logrotate_missingok => $ext_logrotate_missingok,
    logrotate_dateext   => $ext_logrotate_dateext,
    logrotate_compress  => $ext_logrotate_compress,
  }

}
