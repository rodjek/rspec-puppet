# This class is here to test type_with_all_auto which has alll auto* relations
class relationships::type_with_auto {
  type_with_all_auto { 'test':
  }

  notify { ['test/before', 'test/notify', 'test/require', 'test/subscribe']: }
}
