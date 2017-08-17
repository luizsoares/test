class {'postgresql::server':}

postgresql::server::role { 'datadog':
  password_hash => postgresql_password('datadog', 'datadog')
}

class {'datadog_agent':
  api_key => 'da46f1185ebfce0a90279578fba900a2'
}

class {'datadog_agent::integrations::postgres':
  password => 'datadog'
}
