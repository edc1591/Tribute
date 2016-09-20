Pod::Spec.new do |s|
  s.name = 'Tribute'
  s.version = '0.1.5'
  s.license = { :type => 'MIT' }
  s.summary = 'Programmatic creation of NSAttributedString doesn\'t have to be a pain'
  s.homepage = 'https://github.com/edc1591/Tribute'
  s.authors = { 'Sash Zats' => 'sash@zats.io' }
  s.source = { :git => 'https://github.com/edc1591/Tribute.git', :branch => 'swift2.3' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Tribute/*.swift'

  s.requires_arc = true
end
