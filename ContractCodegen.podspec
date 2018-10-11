Pod::Spec.new do |s|
    s.name             = 'ContractCodegen'
    s.version          = '0.0.6'
    s.summary          = 'Generate code from abi.json'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
    s.description      = "Generate code from abi.json using Swift tool."
  
    s.homepage         = 'https://github.com/AckeeCZ/Ethereum-iOS-Dev-Kit'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Ackee' => 'info@ackee.cz' }
    s.source           = { :git => "https://github.com/AckeeCZ/Ethereum-iOS-Dev-Kit.git", :tag => s.version.to_s }
    s.preserve_paths = 'ContractCodegen/bin/contractgen', 'ContractCodegen/Rakefile', 'ContractCodegen/templates/**', 'ContractCodegen/LICENSE'
    s.ios.deployment_target = "10.0"
    s.swift_version = "4.2"
    s.dependency 'EtherKit', '~> 0.2.0'
    s.dependency 'ReactiveSwift', '~> 4.0'        
  end
  