Pod::Spec.new do |s|
  s.name = 'Amazons3'
  s.version = '2.0.0'
  s.license = 'Apache-2.0'
  s.summary = 'Amazon upload bucket'
  s.homepage = 'https://www.spaceotechnologies.com/'
  s.authors = { 'Space-O Technologies' => 'rajan.spaceo@gmail.com' }
  s.source = { :git => 'https://github.com/classified/Amazons3.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.dependency 'AWSCore'
  s.dependency 'AWSS3'
  s.source_files = 'AmazonS3/*'
end
