class relationships::notify {
  notify { 'foo':
    notify => Notify['bar']
  }

  notify { 'bar':
    subscribe => Notify['baz'],
  }

  notify { 'baz': }
  notify { 'gronk': }

  Notify['gronk'] <~ Notify['baz']

  class { '::relationships::notify::pre': } ~>
  class { '::relationships::notify::middle': } ~>
  class { '::relationships::notify::post': }

  file { '/tmp/file.txt': } ~>
  file { '/tmp/directory': } ~>
  service { 'myservice': }
}

class relationships::notify::pre {
  notify { 'pre': }
}

class relationships::notify::middle {
  notify { 'middle': }
}

class relationships::notify::post {
  notify { 'post': }
}
