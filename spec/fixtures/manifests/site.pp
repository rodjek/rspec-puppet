node default {
  notify { 'test': }
}

node /testhost/ {
  include sysctl::common
}

node /gooddephost/ {
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

node /baddephost/ {
  file { '/tmp':
    require => File['/'],
  }
}
