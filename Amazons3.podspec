Pod::Spec.new do |s|
  s.name = 'Amazons3'
  s.version = '1.0'
  s.license = 'Apache-2.0'
  s.summary = 'Amazon upload'
  s.homepage = 'https://www.spaceotechnologies.com/'
  s.authors = { 'Space-O Technologies' => 'rajan.spaceo@gmail.com' }
  s.source = { :git => 'https://github.com/classified/Amazons3.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.dependency 'AWSCore', '2.5.6'
  s.dependency 'AWSS3', '2.5.6'
  s.source_files = 'AmazonS3/*'
end
