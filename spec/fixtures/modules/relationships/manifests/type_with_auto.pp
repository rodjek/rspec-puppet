# This class is here to test type_with_all_auto which has alll auto* relations
class relationships::type_with_auto {
  type_with_all_auto { '/tmp':
  }

  file { ['/tmp/before', '/tmp/notify', '/tmp/require', '/tmp/subscribe']:
    ensure => file,
  }
}
