function Get-PSAutoDownloadRegularExpression
{
    [CmdletBinding()]
    [OutputType([System.String])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('HypertextReference', 'SoftwareVersioning', 'Extensions', 'NugetDependency', 'Architectures')]
        [String]
        $RegularExpression
    )
    Begin
    {
        
    }
    Process
    {
        switch ( $RegularExpression )
        {
            'HypertextReference'    { "href\s*=\s*(?:[""'](?<1>[^""']*)[""']|(?<1>[^>\s]+))" }
            'SoftwareVersioning'    { '(?:\%\d\d)*(\d+\.[\d\.]+\d|\d{3,4})' }
            'Extensions'            { 'exe$|msi$|zip$|7z$|nupkg$|msp$|iso$' }
            'NugetDependency'       { '^https:\/\/www\.powershellgallery\.com\/packages\/(.*)\/$' }
            'Architectures'         { '(x64|x86)?' }
        }
    }
    End
    {
        
    }
}