# Ethereum iOS Dev Kit

## Installation

There are multiple possibilities to install ContractCodegen on your machine or in your project, depending on your preferences and needs. Note that if you do not install `ContractCodegen` using `Cocoapods`, you will have have to import `EtherKit` and `ReactiveSwift` by yourself.

<details>
<summary><strong>Download the ZIP</strong> for the latest release</summary>

* [Go to the GitHub page for the latest release](https://github.com/AckeeCZ/Ethereum-iOS-Dev-Kit/releases/latest)
* Download the `contractcodegen-x.y.z.zip` file associated with that release
* Extract the content of the zip archive in your project directory

We recommend that you **unarchive the ZIP inside your project directory** and **commit its content** to git. This way, **all coworkers will use the same version of ContractCodegen for this project**.

If you unarchived the ZIP file in a folder e.g. called `contractcodegen` at the root of your project directory, you can then invoke ContractCodegen in your Script Build Phase using:

```sh
"$PROJECT_DIR"/contractcodegen/bin/contractcodegen …
```

---
</details>
<details>
<summary>Via <strong>CocoaPods</strong></summary>

If you're using CocoaPods, you can simply add `pod 'ContractCodegen'` to your `Podfile`.

This will download the `ContractCodegen` binaries and dependencies in `Pods/` during your next `pod install` execution.

Given that you can specify an exact version for ``ContractCodegen`` in your `Podfile`, this allows you to ensure **all coworkers will use the same version of ContractCodegen for this project**.

You can then invoke ContractCodegen from your terminal:
```sh
Pods/ContractCodegen/ContractCodegen/bin/contractcodegen …
```

_Note: ContractCodegen isn't really a pod, as it's not a library your code will depend on at runtime; so the installation via CocoaPods is just a trick that installs the ContractCodegen binaries in the Pods/ folder, but you won't see any swift files in the Pods/ContractCodegen group in your Xcode's Pods.xcodeproj. That's normal: the ContractCodegen binary is still present in that folder in the Finder._

---
</details>
<details>
<summary><strong>System-wide installation</strong></summary>

* [Go to the GitHub page for the latest release](https://github.com/AckeeCZ/Ethereum-iOS-Dev-Kit/releases/latest)
* Download the `contractcodegen-x.y.z.zip` file associated with that release
* Extract the content of the zip archive

1. `cd` into the unarchived directory 
2. `make install`
3. You then invoke contractgen simply with `contractgen ...`

</details>

### iOS MVVM Project Template

We have also created iOS MVVM Project Template, so setting your project has never been easier. 
Easily follow the [installation instructions](https://github.com/AckeeCZ/iOS-MVVM-ProjectTemplate).
After you are done, add `name_of_your_abi.json` file to `Resources`. Then add `ContractCodegen` to your `Podfile`, do `pod install` and run this command in your project root directory:
```sh
Pods/ContractCodegen/ContractCodegen/bin/contractgen HelloContract NameOfYourProject/Resources/abi.json -x NameOfYourProject.xcodeproj -o NameOfYourProject/Model/Generated/GeneraredContracts
```

## Usage

### Codegen
The standard usage looks like this `contractgen HelloContract path_to_abi/abi.json -x path_to_xcodeproj/project.xcodeproj -o relative_output_path`

Please <strong>note</strong> that the output path option (`--output`) should be relative to your project - if your generated files are in `YourProjectName/MainFolder/GeneratedContracts` folder, then you should write `--output MainFolder/GeneratedContracts`
For your projects to be bound you also <strong>must</strong> set the `--xcode` option as well. Otherwise you will have to drag the files to your projects manually.

### Usage of Generated Codes

The standard call using code created by `codegen` looks like this:
```swift
import ReactiveSwift
import EtherKit 
let helloWorldContractAddress = try! Address(describing: "0x7cA5E6a3200A758B146C17D4E3a4E47937e79Af5")
let query = EtherQuery(URL(string: "infrastructure-url")!, connectionMode: .http)
query.helloContract(at: helloWorldContractAddress).greet(greetString: "Greetings!").send(using: key, amount: Wei(1)).start()
``` 

`key` should be of protocol `PrivateKeyType` (more at [EtherKit documentation](https://github.com/Vaultio/EtherKit))
Also note that right now the created code works with `ReactiveSwift` only.

If the contract function is `non-payable`, the syntax is almost the same (`amount` is omitted):
```swift
query.helloContract(at: helloWorldContractAddress).greet(greetString: "Greetings!").send(using: key).start()
```

Result of the call is either a `Hash` of the transaction or an `EtherKitError`.
