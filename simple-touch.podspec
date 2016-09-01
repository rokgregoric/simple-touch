Pod::Spec.new do |s|
  s.name         = "SimpleTouch"
  s.version      = "1.0"
  s.summary      = "Very simple swift wrapper for Biometric Authentication Services (Touch ID) on iOS."
  s.homepage     = "https://github.com/Final/simple-touch"
  s.license      = "MIT"
  s.author       = { "Simple Machines" => "hello@simplemachines.com.au" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/Final/simple-touch.git", :tag => s.version.to_s }
  s.source_files = "SimpleTouch/*.swift"
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
end
