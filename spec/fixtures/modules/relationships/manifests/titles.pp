class relationships::titles {
  file { "/etc/svc":
    ensure => present,
    notify => Service["svc-name"],
  }

  service { "svc-title":
    ensure => running,
    name   => "svc-name",
  }
}
