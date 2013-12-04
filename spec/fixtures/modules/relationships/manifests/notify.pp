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
}
