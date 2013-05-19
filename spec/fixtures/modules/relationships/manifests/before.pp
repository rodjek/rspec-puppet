class relationships::before {
  notify { 'foo':
    before => Notify['bar']
  }

  notify { 'bar': }
  notify { 'baz': }

  Notify['foo'] -> Notify['baz']
  Notify['baz'] <- Notify['bar']
}
