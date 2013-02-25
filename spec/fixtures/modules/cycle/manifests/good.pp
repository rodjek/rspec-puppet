class cycle::good {
  notify {
    'foo':
      require => Notify['bar'];
    'bar': ;
  }
}
