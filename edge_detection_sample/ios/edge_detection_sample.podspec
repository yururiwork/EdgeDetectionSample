#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint edge_detection_sample.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'edge_detection_sample'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/yururiwork/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'yururiwork' => 'info@yururiwork.net' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{swift,c,m,h,mm,cpp,plist}'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'

  s.preserve_paths = 'opencv2.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework opencv2' }
  s.vendored_frameworks = 'opencv2.framework'
  s.frameworks = 'AVFoundation'
  s.library = 'c++'
end
