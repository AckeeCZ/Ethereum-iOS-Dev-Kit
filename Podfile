platform :ios, '10.3'
project 'EthereumProjectTemplate', 'AdHoc' => :release,'AppStore' => :release, 'Development' => :debug

inhibit_all_warnings!
use_frameworks!

target 'EthereumProjectTemplate' do
    pod 'SwiftLint', '~> 0.27'
    pod 'EtherKit', :git => 'git@github.com:Vaultio/EtherKit.git'
    
    pod 'ACKLocalization', '~> 0.2'
    pod 'SwiftGen', '~> 5.3'
    pod 'Smartling.i18n', '~> 1.0'

    pod 'Crashlytics', '~> 3.10'
    pod 'Firebase', '~> 5.6', :subspecs => ["RemoteConfig", "Performance", "Analytics", "Messaging"]
    
    target 'UnitTests' do
        inherit! :complete
    end
end
