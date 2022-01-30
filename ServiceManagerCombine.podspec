Pod::Spec.new do |spec|

spec.name         = "ServiceManagerCombine"
spec.version      = "1.0.0"
spec.summary      = "Service Manager written purely on UrlSession and Combine."

spec.description  = <<-DESC
This CocoaPods library helps you perform Service Calls.
DESC

spec.homepage     = "https://github.com/hbhasin3/ServiceManagerCombine"
spec.license      = { :type => "MIT", :file => "LICENSE" }
spec.author       = { "Harsh" => "harsh.bhasin@yahoo.com" }

spec.ios.deployment_target = "13.0"
spec.swift_version = "5.0"

spec.source        = { :git => "https://github.com/hbhasin3/ServiceManagerCombine.git", :tag => "#{spec.version}" }
spec.source_files  = "ServiceManagerCombine/**/*.{h,m,swift}"

end
