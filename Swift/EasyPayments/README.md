# EasyPayments Sample

The EasyPayments sample demonstrates using Defender for iOS in an application that makes use of Storyboards and Core Data.

Defender for iOS renames not just classes but also resources in Storyboard and Core Data.

The EasyPayments sample demonstrates how to obfuscate resource dependent classes and configure tool to selectively exclude classes.

## Building the EasyPayments Sample

The EasyPayments sample can be built from Xcode. 


## Obfuscating EasyPayments Sample

defenderForIos -c ./config.yaml --license '[<key>:<email>](https://www.preemptive.com/defenderforios/standard/userguide/en/introduction_licensing.html)' --build-scheme EasyPayments EasyPayments.xcodeproj

The EasyPayments sample contains a sample Defender for iOS config file that demonstrates using exclusion rules to exclude classes that prevent successful build and runtime execution of the obfuscated app.
This file is named **config.yaml** and can be located in the same directory as the EasyPayments sample.
The section of the file that excludes these references is:

renaming:
  exclude: [window,SceneDelegate,saveContext]


The `<renaming>` tag indicates that the exclusion rules contained within pertain specifically to identifier renaming, as opposed to other Dotfuscator features which can also be selectively turned on or off.

The `<excludelist>` tag defines a list of items that must be excluded from the renaming process.

https://www.preemptive.com/defenderforios/standard/userguide/en/cli_config_file.html

## Summary of the EasyPayments Sample

In order to obfuscate an application that exchanges serialized objects with external applications, you need to make sure that the appropriate data elements are excluded from the renaming process.
Dotfuscator provides extremely powerful mechanism for defining these exclusion rules.
By following these guidelines, you can help ensure that your obfuscated application can safely exchange data with non-obfuscated applications with ease.
