# config for kernel settings
# copied from puppet os hardening module - see hardening.io for details
#

# SoC - Requirement 3.21-1 - Betriebssystemfunktionen, die nicht fuer den Betrieb eines Servers benoetigt werden, muessen abgeschaltet werden.
# SoC - Requirement 3.21-3 - Falls vorhanden, muss die Funktion fuer "rp_filter" (Reverse Path Filter) bzw. eine entsprechende Funktion des verwendeten Derivates gesetzt sein. Ebenso muss "strict destination multihoming" aktiviert sein.
# SoC - Requirement 3.21-5 - Der Schutz vor Buffer Overflows muss aktiviert sein.
# SoC - Requirement 3.37-6 - Netzfunktionen im Betriebssystemkern, die fuer den Betrieb als Server nicht benoetigt werden, muessen abgeschaltet werden.
# SoC - Requirement 3.37-10 - Das System darf keine IP-Pakete verarbeiten, deren Absenderadresse nicht ueber die Schnittstelle erreicht wird, an der das Paket eingegangen ist.
# SoC - Requirement 3.37-11 - Die Verarbeitung von ICMPv4 und ICMPv6 Paketen, die fuer den Betrieb nicht benoetigt werden, muss deaktiviert werden.
# SoC - Requirement 3.37-12 - IP-Pakete mit nicht benoetigten Optionen oder Erweiterungs-Headern duerfen nicht bearbeitet werden.
class secc_os_linux::kernel (
  $enable_ipv4_forwarding,
  $enable_ipv6,
  $enable_ipv6_forwarding,
  $arp_restricted,
  $enable_stack_protection,
){

  # Networking
  # ----------

  # IPv6 enabled
  if $enable_ipv6 {

    file_line { 'kernel_enable_IPv6' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv6.conf.all.disable_ipv6 = 0',
      match  => 'net.ipv6.conf.all.disable_ipv6.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
    }

    if $enable_ipv6_forwarding {

      file_line { 'kernel_enable_IPv6_routing' :
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv6.conf.all.forwarding = 1',
        match  => 'net.ipv6.conf.all.forwarding.*',
        notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
      }


    } else {

        file_line { 'kernel_disable_IPv6_routing' :
          ensure => present,
          path   => '/etc/sysctl.conf',
          line   => 'net.ipv6.conf.all.forwarding = 0',
          match  => 'net.ipv6.conf.all.forwarding.*',
          notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
        }

    }
  } else {
    # IPv6 disabled - only the relevant taken

      file_line { 'kernel_disable_IPv6_completely' :
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv6.conf.all.disable_ipv6 = 1',
        match  => 'net.ipv6.conf.all.disable_ipv6.*',
        notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
      }

      file_line { 'kernel_disable_IPv6_routing' :
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv6.conf.all.forwarding = 0',
        match  => 'net.ipv6.conf.all.forwarding.*',
        notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
      }

  }

  # Only enable IP traffic forwarding, if required.
  if $enable_ipv4_forwarding {
    file_line { 'kernel_disable_IPv4_routing' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.ip_forward = 1',
      match  => 'net.ipv4.ip_forward.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
    }
  } else {
    file_line { 'kernel_disable_IPv4_routing' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.ip_forward = 0',
      match  => 'net.ipv4.ip_forward.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
    }
  }

  # Enable RFC-recommended source validation feature. It should not be used for routers on complex networks, but is helpful for end hosts and routers serving small networks.
  file_line { 'kernel_enable_IPv4_reverse_path_filtering' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.all.rp_filter = 1',
    match  => 'net.ipv4.conf.all.rp_filter.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_enable_IPv4_reverse_path_filtering_default' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.default.rp_filter = 1',
    match  => 'net.ipv4.conf.default.rp_filter.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  # Reduce the surface on SMURF attacks. Make sure to ignore ECHO broadcasts, which are only required in broad network analysis.
  file_line { 'kernel_IPv4_ignore_icmp_broadcasts' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.icmp_echo_ignore_broadcasts = 1',
    match  => 'net.ipv4.icmp_echo_ignore_broadcasts.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_IPv4_log_bad_network_messages' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.icmp_ignore_bogus_error_responses = 1',
    match  => 'net.ipv4.icmp_ignore_bogus_error_responses.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_IPv4_do_not_accept_source_routing' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.all.accept_source_route = 0',
    match  => 'net.ipv4.conf.all.accept_source_route.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  # Accepting source route can lead to malicious networking behavior, so disable it if not needed.
  file_line { 'kernel_IPv4_do_not_accept_source_routing_default' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.default.accept_source_route = 0',
    match  => 'net.ipv4.conf.default.accept_source_route.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  # Accepting source route can lead to malicious networking behavior, so disable it if not needed.
  file_line { 'kernel_IPv4_do_not_accept_redirects' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.all.accept_redirects = 0',
    match  => 'net.ipv4.conf.all.accept_redirects.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_IPv4_do_not_accept_redirects_default' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.default.accept_redirects = 0',
    match  => 'net.ipv4.conf.default.accept_redirects.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_IPv4_do_not_accept_secure_redirects' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.all.secure_redirects = 0',
    match  => 'net.ipv4.conf.all.secure_redirects.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_IPv4_do_not_accept_secure_redirects_default' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.default.secure_redirects = 0',
    match  => 'net.ipv4.conf.default.secure_redirects.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  # For non-routers: don't send redirects, these settings are 0
  file_line { 'kernel_IPv4_do_not_send_redirects' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.all.send_redirects = 0',
    match  => 'net.ipv4.conf.all.send_redirects.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }
  file_line { 'kernel_IPv4_do_not_send_redirects_default' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.default.send_redirects = 0',
    match  => 'net.ipv4.conf.default.send_redirects.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }


  file_line { 'kernel_IPv4_tcp_sync_protection' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.tcp_syncookies = 1',
    match  => 'net.ipv4.tcp_syncookies.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_IPv4_icmp_ratelimit' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.icmp_ratelimit = 100',
    match  => 'net.ipv4.icmp_ratelimit.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_IPv4_icmp_ratemask' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.icmp_ratemask = 88089',
    match  => 'net.ipv4.icmp_ratemask.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line { 'kernel_IPv4_tcp_timestamps' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.tcp_timestamps = 0',
    match  => 'net.ipv4.tcp_timestamps.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }


  # ARP control
  if $arp_restricted {

    file_line { 'kernel_IPv4_arp_ignore' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.conf.all.arp_ignore = 1',
      match  => 'net.ipv4.conf.all.arp_ignore.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
    }

    file_line { 'kernel_IPv4_arp_ignore_default' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.conf.default.arp_ignore = 1',
      match  => 'net.ipv4.conf.default.arp_ignore.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
    }

    file_line { 'kernel_IPv4_arp_filter' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.conf.all.arp_filter = 1',
      match  => 'net.ipv4.conf.all.arp_filter.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
    }

    file_line { 'kernel_IPv4_arp_announce_interface' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.conf.all.arp_announce = 2',
      match  => 'net.ipv4.conf.all.arp_announce.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
      
    }

    file_line { 'kernel_IPv4_arp_announce_interface_default' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.conf.default.arp_announce = 2',
      match  => 'net.ipv4.conf.default.arp_announce.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
    }

  } else {

      file_line { 'kernel_IPv4_arp_dont_ignore' :
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv4.conf.all.arp_ignore = 0',
        match  => 'net.ipv4.conf.all.arp_ignore.*',
        notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
      }

      file_line { 'kernel_IPv4_arp_announce_interface' :
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv4.conf.all.arp_announce = 2',
        match  => 'net.ipv4.conf.all.arp_announce.*',
        notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
      }

      file_line { 'kernel_IPv4_arp_announce_interface_default' :
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv4.conf.default.arp_announce = 2',
        match  => 'net.ipv4.conf.default.arp_announce.*',
        notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
      }

      file_line { 'kernel_IPv4_arp_filter' :
        ensure => present,
        path   => '/etc/sysctl.conf',
        line   => 'net.ipv4.conf.all.arp_filter = 1',
        match  => 'net.ipv4.conf.all.arp_filter.*',
        notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
      }
  }


  # RFC 1337 fix F1
  # This note describes some theoretically-possible failure modes for TCP connections and discusses possible remedies.
  # In particular, one very simple fix is identified.
  file_line { 'kernel_IPv4_rfx1337_f1_fix' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.tcp_rfc1337 = 1',
    match  => 'net.ipv4.tcp_rfc1337.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }


  # log martian packets (risky, may cause DoS)
  file_line {'kernel_IPv4_log_faked_network_packets':
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.all.log_martians = 1',
    match  => 'net.ipv4.conf.all.log_martians.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  file_line {'kernel_IPv4_log_faked_network_packets_default':
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.default.log_martians = 1',
    match  => 'net.ipv4.conf.default.log_martians.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  # Magic Sysrq should be disabled, but can also be set to a safe value if so desired for physical machines.
  # It can allow a safe reboot if the system hangs and is a 'cleaner' alternative to hitting the reset button.
  # The following values are permitted:
  #
  # * **0** - disable sysrq
  # * **1** - enable sysrq completely
  # * **>1** - bitmask of enabled sysrq functions:
  # * **2** - control of console logging level
  # * **4** - control of keyboard (SAK, unraw)
  # * **8** - debugging dumps of processes etc.
  # * **16** - sync command
  # * **32** - remount read-only
  # * **64** - signalling of processes (term, kill, oom-kill)
  # * **128** - reboot/poweroff
  # * **256** - nicing of all RT tasks

  file_line { 'kernel_magic_sysrq' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'kernel.sysrq = 0',
    match  => 'kernel.sysrq.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }


  # Prevent core dumps with SUID. These are usually only needed by developers and may contain sensitive information.
  file_line { 'kernel_core_dump_suid' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'fs.suid_dumpable = 0',
    match  => 'fs.suid_dumpable.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }


  # buffer overflow protection
  file_line { 'kernel_random_va_space' :
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'kernel.randomize_va_space = 2',
    match  => 'kernel.randomize_va_space.*',
    notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
  }

  if Integer.new($::operatingsystemmajrelease) < 7 {
    file_line { 'kernel_exec_shield' :
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'kernel.exec-shield = 1',
      match  => 'kernel.exec-shield.*',
      notify => [Exec['sysctl_load'], Exec['rebuild_initramfs']],
    }
  }

  exec { 'sysctl_load':
    command     => '/sbin/sysctl -p /etc/sysctl.conf',
    refreshonly => true,
  }

  # the initramfs has to be rebuild on every change in the sysctl.conf
  # documentation: https://access.redhat.com/solutions/453703
  # possible problems: https://access.redhat.com/solutions/2798411
  # JIRA Issue: https://jira.t-systems-mms.eu/browse/ASC-234
  exec { 'rebuild_initramfs':
    command     => 'dracut -f',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
    refreshonly => true,
  }

}
