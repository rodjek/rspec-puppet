class structured_facts::hash {
  $_os_family = $facts['os']['family']
  notify { "$_os_family": }
}

