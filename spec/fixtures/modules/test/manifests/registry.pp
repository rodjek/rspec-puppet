class test::registry {
  registry::value { 'puppetmaster':
    key  => 'HKLM\Software\Vendor\PuppetLabs',
    data =>  'puppet.puppetlabs.com',
  }
}
