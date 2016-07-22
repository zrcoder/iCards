Pod::Spec.new do |s|

  s.name         = "iCards"
  s.version      = "1.0.2"
  s.license      = "Copyright (c) 2016 Ding"
  s.summary      = "A containner of views (like cards) can be dragged!"
  s.homepage     = "https://github.com/DingHub/iCards"
  s.license      = "MIT"
  s.author       = { "DingHub" => "love-nankai@163.com" }
  s.source       = { :git => "https://github.com/DingHub/iCards.git", :tag => "1.0.2" }
  s.source_files  = "src/iCards.{h,m}"
  s.platform     = :ios
  s.platform     = :ios, "7.0"
  s.requires_arc = true

end
