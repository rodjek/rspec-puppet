class relationships::before {
  notify { 'foo':
    before => [Notify['bar']],
  }

  notify { 'bar': }
  notify { 'baz': }

  file { '/tmp/foo': ensure => directory }
  file { '/tmp/foo/bar': ensure => file, group => 'foo' }

  notify { 'bazz': before => File['/tmp/foo'] }
  notify { 'qux': require => File['/tmp/foo/bar'] }

  Notify['foo'] -> Notify['baz']
  Notify['baz'] <- Notify['bar']

  class { '::relationships::before::pre': } ->
  class { '::relationships::before::middle': } ->
  class { '::relationships::before::post': }
}

class relationships::before::pre {
  notify { 'pre': }
}

class relationships::before::middle {
  notify { 'middle': }
}

class relationships::before::post {
  notify { 'post': }
}
