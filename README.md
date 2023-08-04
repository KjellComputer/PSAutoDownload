# PSAutoDownload #Just notes for now and short examples

PSAutoDownload is a module that stores runable code in signed XML-files and processes them for the purpose of maintaining a local repository of software files.
The solution consists of small helper functions that will find the right url for downloading software, identifying the name of the file to download, and parse the downloaded files to identify potential file versions.

The first command to run is to initialize the environment: Initialize-PSAutoDownloadRepository -Path C:\Demo\

![bilde](https://github.com/KjellComputer/PSAutoDownload/assets/108197286/98083659-7ff5-40b1-a605-7b8206bc75dd)

When creating recipes to process, the command to be run must be a string thats included in the command to create recipes. These will then be approved by another command that can be scheduled and the XML will also be signed. Only signed recipes will be processed.

![bilde](https://github.com/KjellComputer/PSAutoDownload/assets/108197286/d18474d0-e8ef-46eb-89f8-00aef4ba96ec)

Downloading files found by the commands in the recipes are done with the Invoke-PSAutoDownload command.

![bilde](https://github.com/KjellComputer/PSAutoDownload/assets/108197286/3ed917bb-462f-4f0c-b51c-80fcd72e0dfd)

Using Winget and parsing the yaml-files from the community repository it's possible to use Get-PSAutoDownloadUri to filter out spesific versions of software, example to maintain a local repository of Powershell 7 versions:

![bilde](https://github.com/KjellComputer/PSAutoDownload/assets/108197286/2c30f3f0-e3e4-49fe-8a6c-920215abd182)

![bilde](https://github.com/KjellComputer/PSAutoDownload/assets/108197286/3d741d46-672e-46ce-943c-d8443e5fa880)


