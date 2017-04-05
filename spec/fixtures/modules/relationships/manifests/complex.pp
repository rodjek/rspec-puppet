class relationships::complex {
  notify { 'foo':
    before => Notify['bar'],
  }

  notify { 'bar':
    before => Notify['baz'],
  }

  notify { 'baz':
  }

  Notify['baz'] -> Notify['foo']
}
