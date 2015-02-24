Pod::Spec.new do |s|
  s.name          = 'DHKFabulous'
  s.version       = '1.5.4'
  s.license       = 'MIT'
  s.summary       = 'DHKit Floating Action Button tool.'
  s.homepage      = 'http://gitlab.duethealth.com/groups/ios-projects'
  s.author        = 'Tyler Hugenberg'
  s.source        = 'git@gitlab.duethealth.com:ios-projects/dhkfabulous.git'
  s.source_files  = 'DHKFabulous/Classes/**'
  s.requires_arc  = true
  s.ios.deployment_target = '7.0'
  s.dependency 'ReactiveCocoa', '~> 2.4'
end
