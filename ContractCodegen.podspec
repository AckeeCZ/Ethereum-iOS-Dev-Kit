Pod::Spec.new do |s|
    s.name             = 'ContractCodegen'
    s.version          = '0.0.1-alpha'
    s.summary          = 'Generate code from abi.json'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
    s.description      = <<-DESC
  Generate code from abi.json using Swift tool.
                         DESC
  
    s.homepage         = 'https://github.com/AckeeCZ/Ethereum-iOS-Dev-Kit'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Ackee' => 'info@ackee.cz' }
    s.source           = { http: "https://github.com/AckeeCZ/Ethereum-iOS-Dev-Kit/releases/download/#{s.version}/contractcodegen-#{s.version}.zip" }
    s.preserve_paths   = '*'
    s.exclude_files    = '**/file.zip'
  end
  