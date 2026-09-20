Pod::Spec.new do |s|
  s.name             = 'Core'
  s.version          = '0.1.0'
  s.summary          = 'Tipos e infraestrutura compartilhados do BankApp (Coordinator, Entities, cliente de API).'
  s.homepage         = 'https://github.com/arthurconforti/bankapp-ios-demo'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Arthur Borges Conforti' => '' }
  s.source           = { :path => '.' }
  s.swift_version    = '5.9'
  s.ios.deployment_target = '16.0'
  s.source_files     = 'Classes/**/*.swift'
end
