class deferred {
  $s = Deferred('deferred::upcase', ['a string'])

  notify { 'deferred msg':
    message => $s,
  }
}
