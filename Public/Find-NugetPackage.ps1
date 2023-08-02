function Find-NugetPackage
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String[]]
        $Name,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [ValidateSet('PowershellGallery')]
        [String]
        $Provider = 'PowershellGallery'
    )
    Begin
    {
        $DependencyRegex = Get-PSAutoDownloadRegex -Name nugetdependency
    }
    Process
    {
        foreach ($Nuget in $Name)
        {
            switch ($Provider)
            {
                'powershellgallery'
                {
                    $NugetDownloadUrl = 'https://www.powershellgallery.com/api/v2/package/{0}' -f $Nuget

                }
            }
            
            #Get-PSAutoDownloadUrl -Url $NugetDownloadUrl -RedirectUrl

            $NugetPage = $NugetDownloadUrl | Get-PSAutoDownloadRedirectUrl

            $NugetPackageUrl = 'https://www.powershellgallery.com/packages/{0}' -f $Nuget
            NugetDependency = Get-PSAutoDownloadHrefUrl -Url $NugetPackageUrl | 
                                Select-Object -ExpandProperty Href | 
                                Select-String -Pattern $DependencyRegex | 
                                Select-Object -Property @{Name = 'Dependency'; Expression = {$_.Matches.Groups[1].Value}}
            
            foreach ($Dependency in $NugetDependency)
            {
                $NugetDependencyDownloadUrl = 'https://www.powershellgallery.com/api/v2/package/{0}' -f $Dependency.Dependency
                Get-PSAutoDownloadUrl -Url $NugetDependencyDownloadUrl -RedirectUrl
            }

        }
    }
    End
    {
    
    }
}