# ContractCodegen

## Installation

There are multiple possibilities to install ContractCodegen on your machine or in your project, depending on your preferences and needs:

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

You can then invoke ContractCodegen in your Script Build Phase using:

```sh
$PODS_ROOT/ContractCodegen/ContractCodegen/bin/contractcodegen …
```

_Note: ContractCodegen isn't really a pod, as it's not a library your code will depend on at runtime; so the installation via CocoaPods is just a trick that installs the ContractCodegen binaries in the Pods/ folder, but you won't see any swift files in the Pods/ContractCodegen group in your Xcode's Pods.xcodeproj. That's normal: the ContractCodegen binary is still present in that folder in the Finder._

---
</details>
<details>
<summary><strong>System-wide installation</strong></summary>

* [Go to the GitHub page for the latest release](https://github.com/AckeeCZ/Ethereum-iOS-Dev-Kit/releases/latest)
* Download the `contractcodegen-x.y.z.zip` file associated with that release
* Extract the content of the zip archive

cd into the unarchived directory 

`make install`

You then invoke contractgen simply with `contractgen ...`

</details>

## Usage 

The standard usage looks like this `contractgen HelloContract path_to_abi/abi.json -x path_to_xcodeproj/project.xcodeproj -o relative_output_path`

Please <strong>note</strong> that the output path option (`-o`) should be relative to your project - 

If Xcode project path and output path for generated is not given, it generates the code in current directory and you then have to by yourself move the files to the desired Xcode project.

Parts of project were inspired by https://github.com/gnosis/bivrost-swift.
