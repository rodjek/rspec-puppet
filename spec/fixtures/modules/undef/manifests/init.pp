class undef($user = undef) {
  exec { '/bin/echo foo':
    user => $user,
  }
}
