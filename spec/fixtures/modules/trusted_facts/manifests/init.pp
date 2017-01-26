class trusted_facts {
  notify { "certname-${trusted['certname']}": }
  notify { "authenticated-${trusted['authenticated']}": }
  notify { "domain-${trusted['domain']}": }
  notify { "hostname-${trusted['hostname']}": }

  if $trusted['extensions'] == {} {
    notify { "no-extensions": }
  } else {
    $trusted['extensions'].each |$k, $v| {
      notify { "extension-${k}-${v}": }
    }
  }
}
