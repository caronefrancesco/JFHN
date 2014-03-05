Pod::Spec.new do |s|
  s.name             = "MFPPorterStemmer"
  s.version          = "0.2"
  s.summary          = "An Objective-C wrapper around the Porter stemming algorithm."
  s.description      = <<-DESC
                       An algorithm to reduce words to their "stem" version, i.e. "tomatoes" => "tomato". Learn more at http://tartarus.org/martin/PorterStemmer/
                       DESC
  s.license          = 'BSD'
  s.author           = { "jflinter" => "jflinter11@gmail.com" }
  s.homepage         = "https://github.com/jflinter/MFPPorterStemmer"
  s.license          = 'BSD'
  s.author           = { "jflinter" => "jflinter11@gmail.com" }
  s.source           = { :git => "https://github.com/jflinter/MFPPorterStemmer.git", :tag => s.version.to_s }
  s.requires_arc = true

  s.source_files = 'Classes'
end
