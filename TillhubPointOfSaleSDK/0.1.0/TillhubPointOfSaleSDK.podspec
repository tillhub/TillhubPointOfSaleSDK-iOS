#
# Be sure to run `pod lib lint TillhubPointOfSaleSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TillhubPointOfSaleSDK'
  s.version          = '0.1.0'
  s.summary          = 'SDK for the Tillhub POS SDK.'
  s.description      = 'SDK for iOS from TillhubGmbH for the Tillhub POS.'

  s.homepage         = 'https://www.tillhub.de'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'TillhubGmbH' => 'support@tillhub.de' }
  s.source           = { :git => 'https://github.com/tillhub/TillhubPointOfSaleSDK-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'

  s.source_files = 'TillhubPointOfSaleSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TillhubPointOfSaleSDK' => ['TillhubPointOfSaleSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
