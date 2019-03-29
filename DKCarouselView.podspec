Pod::Spec.new do |s|
  s.name         = "DKCarouselView"
  s.version      = "1.5"
  s.summary      = "DKCarouselView is a automatically & circular infinite(or not) scrolling view.The view auto paging/pause can be specified as well. Support also GIFs"
  s.homepage     = "https://github.com/zhangao0086/DKCarouselView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/zhangao0086/DKCarouselView.git", 
                     :tag => s.version.to_s }
  s.source_files  = "DKCarousel/DKCarouselView/*.{h,m}"
  s.frameworks = "Foundation", "UIKit"
  s.requires_arc = true
  s.dependency "SDWebImage/GIF", '~> 4.1'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
