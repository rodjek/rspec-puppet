class exported::export_files {
  @@file { '/foo':
    owner => 'root',
    group => 'root',
  }
  @@file { '/foobar':
    owner => 'daemon',
    group => 'daemon',
  }
  @@file { '/quux':
    owner => 'toor',
    group => 'toor',
  }
  File <| owner != 'toor' |>
  package { 'baz':
    ensure => present,
  }
}
