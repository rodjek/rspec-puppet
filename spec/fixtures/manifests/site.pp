node default {
  notify { 'test': }
}

node 'testhost_a' {
  file { '/tmp/a': }
}

node /testhost/ {
  include sysctl::common
}

node 'good_dep_host' {
  file { 'tmpdir':
    alias => '/tmp',
    path  => '/tmp',
  }
  file { '/tmp/deptest1':
    require => File['tmpdir'],
  }
  file { '/tmp/deptest2':
    require => File['/tmp'],
  }
}

node 'bad_dep_host' {
  file { '/tmp':
    require => File['/'],
  }
}
