# ContractCodegen

## Installation
1. Install zip file from the latest release (for development just git clone)
2. cd into ContractCodegen
3. make install
5. Run `contractgen HelloContract path_to_abi/abi.json -x path_to_xcodeproj/project.xcodeproj -o output_path`

If Xcode project path and output path for generated is not given, it generates the code in current directory and you then have to by yourself move the files to the desired Xcode project.

Parts of project were inspired by https://github.com/gnosis/bivrost-swift.
