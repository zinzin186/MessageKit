Pod::Spec.new do |s|
   s.name = 'MessageKit'
   s.version = '3.6.2'
   s.license = { :type => "MIT", :file => "LICENSE.md" }

   s.summary = 'An elegant messages UI library for iOS.'
   s.homepage = 'https://github.com/MessageKit/MessageKit'
   s.social_media_url = 'https://twitter.com/_SD10_'
   s.author = { "Steven Deutsch" => "stevensdeutsch@yahoo.com" }

   s.source = { :git => 'https://github.com/MessageKit/MessageKit.git', :tag => s.version }
   s.source_files = 'Sources/**/*.swift'

   s.swift_version = '5.0'

   s.ios.deployment_target = '9.0'
   s.ios.resources = ['Sources/Assets.xcassets']
   s.dependency 'InputBarAccessoryView', '~> 4.3.2'
   s.dependency 'GTProgressBar'
end
