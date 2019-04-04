Pod::Spec.new do |s|
  s.name         = "DKCarouselView"
  s.version      = "1.4.12"
  s.summary      = "DKCarouselView is a automatically & circular infinite(or not) scrolling view.The view auto paging/pause can be specified as well. Support also GIFs"
  s.homepage     = "https://github.com/zhangao0086/DKCarouselView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/zhangao0086/DKCarouselView.git", 
                     :branch => "develop" }
  s.source_files  = "DKCarouselView/DKCarouselView/DKCarouselView/*.{h,m}"
  s.frameworks = "Foundation", "UIKit"
  s.requires_arc = true
  s.dependency "SDWebImage/GIF", '~> 4.1'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
