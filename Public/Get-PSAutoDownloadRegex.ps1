function Get-PSAutoDownloadRegex
{
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('href','programversion','extensions','nugetdependency')]
        [String[]]
        $Name
    )
    Begin
    {
        
    }
    Process
    {
        foreach ($Regex in $Name)
        {
            switch ($Regex)
            {
                'href' {"href\s*=\s*(?:[""'](?<1>[^""']*)[""']|(?<1>[^>\s]+))"}
                'programversion' {'(?:\%\d\d)*(\d+\.[\d\.]+\d|\d{3,4})'}
                'extensions' {'exe$|msi$|zip$|7z$|nupkg$|msp$|iso$'}
                'nugetdependency' {'^https:\/\/www\.powershellgallery\.com\/packages\/(.*)\/$'}
            }
        }
    }
    End
    {
        
    }
}