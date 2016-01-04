Pod::Spec.new do |s|
  s.name         = "SummerWars"
  s.version      = "1.0.0"
  s.summary      = "Displaying like SummerWars."
  s.homepage     = "https://github.com/suzuki-0000/SummerWars"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "suzuki_keishi" => "keishi.1983@gmail.com" }
  s.source       = { :git => "https://github.com/suzuki-0000/SummerWars.git", :tag => "1.0.0" }
  s.platform     = :ios, "8.0"
  s.source_files = "SummerWars/**/*.{h,swift}"
  s.resources    = "SummerWars/SummerWars.bundle"
  s.requires_arc = true
  s.frameworks   = "UIKit"
end
