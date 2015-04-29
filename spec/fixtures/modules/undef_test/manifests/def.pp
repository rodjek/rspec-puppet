define undef_test::def($user = undef) {
  exec { '/bin/echo foo':
    user => $user,
  }
}
