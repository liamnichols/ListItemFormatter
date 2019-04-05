Pod::Spec.new do |s|
  s.name = 'ListItemFormatter'
  s.version = '0.0.1'
  s.license = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.summary = 'Localised list formatting in Swift and Objective-C'
  s.description = 'ListItemFormatter is an NSFormatter subclass that supports formatting list items to the Unicode CLDR specification.'
  s.homepage = 'https://github.com/liamnichols/ListItemFormatter'
  s.author = { 'liamnichols' => 'liam.nichols.ln@gmail.com' }
  s.social_media_url = 'https://twitter.com/liamnichols_'
  s.source = { :git => 'https://github.com/liamnichols/ListItemFormatter.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'

  s.swift_version = '4.2'
  s.source_files  = "Source/**/*.{h,swift}"
  s.resources = 'Source/*.xcassets'
end
