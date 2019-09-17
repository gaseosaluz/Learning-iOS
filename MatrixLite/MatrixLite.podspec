Pod::Spec.new do |s|
  s.name = "MatrixLite"
  s.version = "0.1.0"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.summary = "Lightweight Accelerated Matrix Library for Swift"
  s.homepage = "https://gitlab.com/weareset/MatrixLite"
  s.social_media_url = "https://twitter.com/EverySet"
  s.authors = { "Set Team" => "team@set.gl" }
  s.source = { :git => "https://gitlab.com/weareset/MatrixLite.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.9'

  s.source_files = "Source/*.{swift}"
  s.frameworks = 'Accelerate'
  s.requires_arc = true
end
