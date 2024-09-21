Pod::Spec.new do |s|
  s.name = "OCSIM"
  s.version = "5.3.6"
  s.summary = "A open IM sdk"
  s.homepage = "https://github.com/scalessec/Toast-Swift"
  s.license = 'MIT'
  s.author = { "Charles Scalesse" => "scalessec@gmail.com" }
  s.source = { :git => "https://github.com/scalessec/Toast-Swift.git", :tag => "5.1.1" }
  s.platform = :ios
  s.source_files = 'Sources/**/*.swift'
  s.framework = 'UIKit'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
end
