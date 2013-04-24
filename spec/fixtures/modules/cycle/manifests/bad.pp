class cycle::bad {
  notify {
    'foo':
      require => Notify['bar'];
    'bar':
      require => Notify['foo'];
  }
}
