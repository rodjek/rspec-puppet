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

class boolean($bool) {
  $real_bool = $bool ? {
    true => false,
    false => true,
  }
  
  if ($real_bool) {
    notify {"bool testing":
      message => "This will print when \$bool is false."
    }
  }
}
