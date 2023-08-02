function Find-WinGetPackage
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String[]]
        $Name,

        [Parameter(Mandatory = $False)]
        [String]
        $Path,

        [Parameter(Mandatory = $False)]
        [ValidateRange(1, 99)]
        [Int]
        $Latest
    )
    Begin
    {
        try
        {
            Import-Module -Name powershell-yaml -ErrorAction Stop
        }
        catch 
        {
            Write-Error -Message 'Missing module powershell-yaml'    
        }

        $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

        if ($PSAutoDownloadEnvironmentVariable.WinGet -and $Path.Length -eq 0)
        {
            $Path = $PSAutoDownloadEnvironmentVariable.WinGet
        }
    }
    Process
    {
        foreach ($Package in $Name)
        {
            if ($Latest)
            {
                #$PSAutoPackage = Get-ChildItem -Path $Path -Recurse -Directory -Filter $Package | Get-ChildItem -Directory | Sort-Object -Property {$_.Name -as [System.Version]} -Descending | Select-Object -First $Latest
                #Go speed go
                $PSAutoPackage = [System.IO.Directory]::EnumerateDirectories($Path, $Package, [System.IO.SearchOption]::AllDirectories)
                $PSAutoPackage = $PSAutoPackage | Get-ChildItem -Directory | Sort-Object -Property {$_.Name -as [System.Version]} -Descending | Select-Object -First $Latest
                #$PSAutoPackage = [System.IO.Directory]::EnumerateDirectories($PSAutoPackage) | Sort-Object -Property {$_.Name -as [System.Version]} -Descending | Select-Object -First $Latest
            }
            else 
            {
                #$PSAutoPackage = Get-ChildItem -Path $Path -Recurse -Directory -Filter $Package | Get-ChildItem -Directory
                #Go speed go
                $PSAutoPackage = [System.IO.Directory]::EnumerateDirectories($Path, $Package, [System.IO.SearchOption]::AllDirectories)
                $PSAutoPackage =  $PSAutoPackage | Get-ChildItem -Directory
            }
            
            if ($PSAutoPackage)
            {
                $YamlInstallerFiles = $PSAutoPackage | Get-ChildItem -Recurse -Filter '*.installer.yaml'# | Select-Object -Unique

                if (-not($YamlInstallerFiles))
                {
                    $YamlInstallerFiles = $PSAutoPackage | Get-ChildItem -Recurse -Filter '*.yaml'#| Select-Object -Unique
                }

                foreach ($Yaml in $YamlInstallerFiles)
                {
                    $PSAutoPackageInformation = [PSCustomObject]($Yaml | Get-Content | ConvertFrom-Yaml)
                    
                    $PSAutoPackageInstallers = $PSAutoPackageInformation.Installers | ForEach-Object -Process {[PSCustomObject]$_}
                    
                    foreach ($PSAutoPackageInstaller in $PSAutoPackageInstallers)
                    {
                        if ($PSAutoPackageInformation.InstallerType)
                        {
                            $InstallerType = $PSAutoPackageInformation.InstallerType    
                        }
                        else
                        {
                            $InstallerType = $PSAutoPackageInstaller.InstallerType    
                        }

                        [PSCustomObject]@{
                            PackageIdentifier = $PSAutoPackageInformation.PackageIdentifier
                            InstallerType = $InstallerType
                            PackageVersion = $PSAutoPackageInformation.PackageVersion
                            Architecture = $PSAutoPackageInstaller.Architecture
                            InstallerSha256 = $PSAutoPackageInstaller.InstallerSha256
                            InstallerUrl = $PSAutoPackageInstaller.InstallerUrl
                        }
                    }
                }
            }
        }
    }
    End
    {
        
    }
}