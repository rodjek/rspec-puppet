class structured_facts::top_scope {
  $_os_family = $::os['family']
  notify { "$_os_family": }
}
