#
# Be sure to run `pod lib lint AsyncTimeoutOperationQueue.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AsyncTimeoutOperationQueue'
  s.version          = '0.4'
  s.summary          = 'Async NSOperation with timeouts'

  s.description      = 'Async NSOperation with timeout, onTimeout and onCompletion calls'

  s.homepage         = 'https://github.com/severehed/AsyncTimeoutOperationQueue'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'severehed'
  s.source           = { :git => 'https://github.com/severehed/AsyncTimeoutOperationQueue.git', :tag => s.version.to_s }

  s.swift_version = '4.0'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target  = '10.10'

  s.ios.framework  = 'Foundation'
  s.osx.framework  = 'Foundation'

  s.source_files = 'AsyncTimeoutOperationQueue/Classes/**/*'

end
