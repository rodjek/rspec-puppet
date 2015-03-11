class relationships::before {
  notify { 'foo':
    before => [Notify['bar']],
  }

  notify { 'bar': }
  notify { 'baz': }

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
