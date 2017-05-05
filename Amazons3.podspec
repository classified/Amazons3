Pod::Spec.new do |s|  
    s.name              = ‘Amazons3’
    s.version           = '1.0.0'
    s.summary           = ‘Uploading to s3 made easier by this framework’
    s.homepage          = 'https://www.spaceotechnologies.com/'

    s.author            = { 'Name' => ‘Rajan Palaniya’ }
    s.license           = { :type => 'Apache-2.0', :file => 'LICENSE' }

    s.platform          = :ios
    s.source            = { :http => 'http://example.com/sdk/1.0.0/MySDK.zip' }

    s.ios.deployment_target = '8.0'
    s.ios.vendored_frameworks = 'Amazons3.framework'
end 