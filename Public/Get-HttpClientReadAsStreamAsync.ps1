function Get-HttpClientReadAsStreamAsync
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Url,

        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [System.Net.Http.HttpClient]
        $HttpClient
    )
    Begin
    {

    }
    Process
    {
       $HttpClient.GetAsync($Url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult().Content.ReadAsStreamAsync()
    }
    End
    {

    }
}