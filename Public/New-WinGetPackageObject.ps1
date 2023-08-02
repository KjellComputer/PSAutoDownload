function New-WinGetPackageObject
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject[]]
        $WinGetObject,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String[]]
        $Architecture,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String[]]
        $Extension,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String[]]
        $PackageVersion,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String[]]
        $PackageIdentifier,
        
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String[]]
        $Exclude
    )
    Begin
    {

    }
    Process
    {
        foreach ($WinGetPackage in $WinGetObject)
        {
            if ($Extension)
            {
                $Extensions = ($Extension | ForEach-Object -Process {$_.Insert($_.Length, '$')}) -join '|'
                $WinGetPackage = $WinGetPackage | Where-Object -Property InstallerType -match $Extensions
            }

            if ($Arch)
            {
                $Architectures = $Arch -join '|'
                $WinGetPackage = $WinGetPackage | Where-Object -Property Architecture -match $Architectures
            }
             
            if ($Exclude)
            {
                $Excludes = $Exclude -join '|'
                $WinGetPackage | Where-Object -FilterScript {$_ -notmatch $Excludes}
            }

            if ($WinGetPackage)
            {
                $WinGetPackage
            }
        }        
    }
    End
    {

    }
}