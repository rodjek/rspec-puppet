class sysctl::common {
  exec { 'sysctl/reload':
    command     => '/sbin/sysctl -p /etc/sysctl.conf',
    refreshonly => true,
    returns     => [0, 2],
  }
}

define sysctl($value) {
  include sysctl::common

  augeas { "sysctl/${name}":
    context => '/files/etc/sysctl.conf',
    changes => "set ${name} '${value}'",
    onlyif  => "match ${name}[.='${value}'] size == 0",
    notify  => Exec['sysctl/reload'],
  }
}

define sysctl::before($value) {
  Class['sysctl::common'] -> Sysctl::Before[$name]

  notify {"message-${name}":
    message => "This should print if the class is here first."
  }
}
