class escape($content = '') {
  file { '/tmp/escape':
    ensure => file,
    content => $content
  }
}
