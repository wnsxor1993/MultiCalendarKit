#
# Be sure to run `pod lib lint MultiCalendarKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MultiCalendarKit'
  s.version          = '1.0.0'
  s.summary          = 'Multi Calendar Kit is a toolkit that allows you to use multiple calendars simultaneously.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This framework provides the ability to use multiple calendars within a single framework. 
  It is designed to facilitate various calendar functionalities, such as inputting values on specific dates for purposes like expense tracking, and selecting multiple dates for vacation or scheduling.
                       DESC

  s.homepage         = 'https://github.com/wnsxor1993/MultiCalendarKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Puco' => 'https://wnsxor1993@github.com' }
  s.source           = { :git => 'https://github.com/wnsxor1993/MultiCalendarKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.7.2'

  s.source_files = 'MultiCalendarKit/Classes/**/*'

  # Dependency
  # RxSwift
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'RxGesture'
  s.dependency 'RxDataSources'

  # SnapKit
  s.dependency 'SnapKit'

  # Then
  s.dependency 'Then'
  
  # s.resource_bundles = {
  #   'MultiCalendarKit' => ['MultiCalendarKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
end
