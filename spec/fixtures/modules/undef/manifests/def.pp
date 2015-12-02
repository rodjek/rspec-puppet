define undef::def($user = undef) {
  exec { '/bin/echo foo' :
    user  => $user,
  }
}
