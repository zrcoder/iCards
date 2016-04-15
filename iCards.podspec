Pod::Spec.new do |s|

  s.name         = "iCards"
  s.version      = "0.0.1"
  s.summary      = "A containner of views (like cards) can be dragged!"
  s.description  = <<-DESC
                   DESC
  s.homepage     = "http://EXAMPLE/iCards"
  s.license      = "MIT (example)"
  s.author             = { "DingHub" => "love-nankai@163.com" }
  s.source       = { :git => "http://EXAMPLE/iCards.git", :tag => "0.0.1" }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  # s.public_header_files = "Classes/**/*.h"

end
