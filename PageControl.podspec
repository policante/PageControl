#
# Be sure to run `pod lib lint PageControl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PageControl'
  s.version          = '1.0.1'
  s.summary          = 'A simple way to navigate between pages by using gestures.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A simple way to navigate between pages by using gestures.
Made with love
                       DESC

  s.homepage         = 'https://github.com/policante/PageControl'
  # s.screenshots     = 'https://github.com/policante/PageControl/blob/master/images/example2.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rodrigo Martins' => 'policante.martins@gmail.com' }
  s.source           = { :git => 'https://github.com/policante/PageControl.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.3'

  s.source_files = 'PageControl/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PageControl' => ['PageControl/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
