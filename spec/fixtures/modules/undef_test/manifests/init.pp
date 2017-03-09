class undef_test($user = undef) {
  exec { '/bin/echo foo':
    user => $user,
  }
}
