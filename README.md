# PSAutoDownload

PSAutoDownload is a module that stores runable code in signed XML-files and processes them for the purpose of maintaining a local repository of software files.
The solution consists of small helper functions that will find the right url for downloading software, identifying the name of the file to download, and parse the downloaded files to identify potential file versions.

The first command to run is to initialize the environment: Initialize-PSAutoDownloadRepository -Path C:\Demo\

![bilde](https://github.com/KjellComputer/PSAutoDownload/assets/108197286/98083659-7ff5-40b1-a605-7b8206bc75dd)

