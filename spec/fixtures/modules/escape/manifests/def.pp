define escape::def($content = '') {
  file { $title :
    ensure  => file,
    content => $content
  }
}
