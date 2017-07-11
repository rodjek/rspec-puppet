class structured_facts::hostname {
  notify { "clientcert:${facts['clientcert']}": }
  notify { "hostname:${facts['hostname']}": }
  notify { "domain:${facts['domain']}": }
  notify { "fqdn:${facts['fqdn']}": }
  notify { "nh-hostname:${facts['networking']['hostname']}": }
  notify { "nh-domain:${facts['networking']['domain']}": }
  notify { "nh-fqdn:${facts['networking']['fqdn']}": }
  notify { "nh-other:${facts['networking']['other']}": }
}
