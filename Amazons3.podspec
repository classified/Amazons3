Pod::Spec.new do |s|  
    s.name              = ‘Amazons3’
    s.version           = '1.0.0'
    s.summary           = ‘Uploading to s3 made easier by this framework’
    s.homepage          = 'https://www.spaceotechnologies.com/'

    s.author            = { 'Name' => ‘Rajan Palaniya’ }
    s.license           = { :type => 'Apache-2.0', :file => 'LICENSE' }

    s.platform          = :ios
    s.source       = { :git => "https://github.com/classified/Amazons3.git", :tag => s.version.to_s }

# ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  CocoaPods is smart about how it includes source code. For source files
#  giving a folder will include any h, m, mm, c & cpp files. For header
#  files it will include any header in the folder.
#  Not including the public_header_files will make all headers public.
#

    s.source_files  = 'Amazons3/*’
    s.ios.frameworks = "Foundation", "MobileCoreServices"
    s.ios.deployment_target = '8.0'
    s.ios.vendored_frameworks = 'Amazons3.framework'
end 