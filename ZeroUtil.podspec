#
# Be sure to run `pod lib lint ZeroUtil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZeroUtil'
  s.version          = '0.0.1'
  s.summary          = 'ZeroUtil is an easy-to-use and powerful tools'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'ZeroUtil is a library of tools, and you can use the sublibraries if you need to, but not the whole set'

  s.homepage         = 'https://github.com/HughPurple/ZeroUtil'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lyp' => 'lyp@zurp.date' }
  s.source           = { :git => 'https://github.com/HughPurple/ZeroUtil.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version         = '4.2'

  s.source_files = 'ZeroUtil/Classes/**/*'

  # s.resource_bundles = {
  #   'ZeroUtil' => ['ZeroUtil/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.subspec 'Log' do |log|
    log.source_files = 'ZeroUtil/Classes/Log/**/*'
  end
end
