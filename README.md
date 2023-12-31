# PSAutoDownload #Just notes for now and short examples

PSAutoDownload is a module that stores runable code in XML-files and processes them for the purpose of maintaining a local repository of software files.
Using XML functionality like encryping XML content and signing the XML with certificates, data tampering of code stored in the XML files should be safe as long as the certificate is protected.
The XML signature is validated against the certificate before continuing to decrypt the content of the XML file with the same certificate or another for extra measurement.

The code can be *custom, but the solution is also build to find the right urls for software and download them as a local repository.

*Tweak Invoke-PSAutoDownload to enable this

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

![bilde](https://github.com/KjellComputer/PSAutoDownload/assets/108197286/b8055a20-5dfc-4e6f-aae0-9b2a95f9aca5)

It's also possible to follow redirected url where the command will follow until it find a url with an extension, this can be slow depending on how many url it prosesses if one only want to download for example msi files:

![bilde](https://github.com/KjellComputer/PSAutoDownload/assets/108197286/1b7ea97b-041f-468d-949d-f870682b2d0a)

In the case of WinSCP, we know or assume that the outfile will follow schemantic versioning, so to save bandwith one can use the -Skip parameter to not download the files again:

$Command = 'Find-WinGetPackage -Name WinSCP -Latest 1 | Get-PSAutoDownloadUri -RedirectUrl -Extension msi | Save-PSAutoDownloadUri -Skip'
