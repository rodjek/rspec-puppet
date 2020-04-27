class trusted_external_data {
  if $trusted['external'] == {} {
    notify { "no-external-data": }
  } else {
    $trusted['external'].each |$k, $v| {
      notify { "external-${k}-${v}": }
    }
  }
}
