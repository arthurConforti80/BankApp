Pod::Spec.new do |s|
  s.name             = 'FeatureFX'
  s.version          = '0.1.0'
  s.summary          = 'Taxas de câmbio exibidas na Home do BankApp.'
  s.homepage         = 'https://github.com/arthurconforti/bankapp-ios-demo'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Arthur Borges Conforti' => '' }
  s.source           = { :path => '.' }
  s.swift_version    = '5.9'
  s.ios.deployment_target = '16.0'
  s.source_files     = 'Classes/**/*.swift'
  s.dependency 'Core'
end
