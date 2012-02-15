node default {
  notify { 'test': }
}

node /testhost/ {
  include sysctl::common
}
