#
# Be sure to run `pod lib lint Snapp.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Snapp"
  s.version          = "1.0.0"
  s.summary          = "Create an app in seconds."
  s.description      = "A plug-and-play library for creating an app."
  s.homepage         = "http://rahuljaswa.com"
  s.license          = 'COMMERCIAL'
  s.author           = { "Rahul Jaswa" => "rahul.jaswa@gmail.com" }
  s.source           = { git: 'https://github.com/rahuljaswa/Snapp.git', :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.{h,m}'
  s.resource_bundles = {
    'Snapp' => ['Pod/Assets/*']
  }

  s.frameworks = 'UIKit'
  s.dependency 'ActionLabel'
  s.dependency 'AFNetworking/NSURLConnection'
  s.dependency 'ChatViewControllers'
  s.dependency 'FastImageCache'
  s.dependency 'Parse'
  s.dependency 'SVProgressHUD'
  s.dependency 'SZTextView'
end
