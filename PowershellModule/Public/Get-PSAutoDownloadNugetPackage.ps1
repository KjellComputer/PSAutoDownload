function Get-PSAutoDownloadNugetPackage
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [System.String[]]
        $Name
    )
    Begin
    {

    }
    Process
    {
        $NugetDependency = Get-PSAutoDownloadRegularExpression -RegularExpression NugetDependency

        foreach ( $Nuget in $Name )
        {
            $NugetDownloadUrl = 'https://www.powershellgallery.com/api/v2/package/{0}' -f $Nuget
            Get-PSAutoDownloadUri -Url $NugetDownloadUrl -RedirectUrl

            $NugetPackageUrl = 'https://www.powershellgallery.com/packages/{0}' -f $Nuget
            $NugetDependency = Get-PSAutoDownloadHypertextReferenceUri -Url $NugetPackageUrl    | 
                                Select-Object -ExpandProperty AbsoluteUri                       | 
                                Select-String -Pattern $NugetDependency                         | 
                                Select-Object -Property @{ Name = 'Dependency'; Expression = { $_.Matches.Groups[1].Value } }
            
            foreach ( $Dependency in $NugetDependency )
            {
                $NugetDependencyDownloadUrl = 'https://www.powershellgallery.com/api/v2/package/{0}' -f $Dependency.Dependency
                Get-PSAutoDownloadUri -Url $NugetDependencyDownloadUrl -RedirectUrl
            }

        }
    }
    End
    {
    
    }
}