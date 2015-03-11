class relationships::before {
  notify { 'foo':
    before => [Notify['bar']],
  }

  notify { 'bar': }
  notify { 'baz': }

  file { '/tmp/foo': ensure => directory }
  file { '/tmp/foo/bar': ensure => file }

  notify { 'bazz': before => File['/tmp/foo'] }
  notify { 'qux': require => File['/tmp/foo/bar'] }

  Notify['foo'] -> Notify['baz']
  Notify['baz'] <- Notify['bar']

  class { '::relationship::before::pre': } ->
  class { '::relationship::before::middle': } ->
  class { '::relationship::before::post': }
}

class relationship::before::pre {
  notify { 'pre': }
}

class relationship::before::middle {
  notify { 'middle': }
}

class relationship::before::post {
  notify { 'post': }
}
