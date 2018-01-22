class server_facts {
  notify { "servername-${server_facts['servername']}": }
  notify { "serverip-${server_facts['serverip']}": }
  notify { "serverversion-${server_facts['serverversion']}": }
  notify { "environment-${server_facts['environment']}": }
}

