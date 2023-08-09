function Get-PSAutoDownloadGitHubUrl
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Owner,

        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Repository
    )
    Begin
    {

    }
    Process
    {
        $GitHubUri = [System.UriBuilder]::new( 'https', 'api.github.com', 443, ( 'repos', $Owner, $Repository, 'releases' -join '/' ) ) | Select-Object -ExpandProperty Uri

        $Request = Invoke-RestMethod -Uri $GitHubUri

        foreach ( $Asset in $Request )
        {
            if ( $Asset.assets )
            {
                foreach ( $BrowerDownloadUrl in $Asset.assets.browser_download_url )
                {
                    [PSCustomObject]@{ Url = $BrowerDownloadUrl }
                }
            }
        }
    }
    End
    {

    }
}