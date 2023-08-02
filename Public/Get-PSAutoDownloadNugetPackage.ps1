function Get-PSAutoDownloadNugetPackage
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String[]]
        $Name
    )
    Begin
    {
        #$DependencyRegex = '^https:\/\/www\.powershellgallery\.com\/packages\/(.*)\/$'
        $DependencyRegex = Get-PSAutoDownloadRegex -Name nugetdependency
    }
    Process
    {
        foreach ($Nuget in $Name)
        {
            $NugetDownloadUrl = 'https://www.powershellgallery.com/api/v2/package/{0}' -f $Nuget
            Get-PSAutoDownloadUrl -Url $NugetDownloadUrl -RedirectUrl

            $NugetPackageUrl = 'https://www.powershellgallery.com/packages/{0}' -f $Nuget
            $NugetDependency = Get-PSAutoDownloadHrefUrl -Url $NugetPackageUrl | 
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