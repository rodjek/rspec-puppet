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

  class { '::relationship::notify::pre': } ~>
  class { '::relationship::notify::middle': } ~>
  class { '::relationship::notify::post': }
}

class relationship::notify::pre {
  notify { 'pre': }
}

class relationship::notify::middle {
  notify { 'middle': }
}

class relationship::notify::post {
  notify { 'post': }
}
