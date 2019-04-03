#
# Be sure to run `pod lib lint ListItemFormatter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = 'ListItemFormatter'
  s.version = '0.0.1'
  s.summary = 'NSFormatter subclass for formatting string arrays as human readable lists.'
  s.description = 'ListItemFormatter is an NSFormatter subclass that supports formatting list items to the Unicode CLDR specification.'
  s.homepage = 'https://github.com/liamnichols/ListItemFormatter'
  s.license = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author = { 'liamnichols' => 'liam-nichols@cookpad.jp' }
  s.source = { :git => 'https://github.com/liamnichols/ListItemFormatter.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/liamnichols_'
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
  s.source_files  = "Source/**/*.{h,swift}"
  s.resources = 'Source/*.xcassets'
end
