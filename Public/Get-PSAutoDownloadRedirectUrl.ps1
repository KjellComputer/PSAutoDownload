function Get-PSAutoDownloadRedirectUrl
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Url
    )
    Begin
    {
        Add-Type -AssemblyName System.Net.Http

        $HttpClient = [System.Net.Http.HttpClient]::new()
        $HttpClient.Timeout = [System.TimeSpan]::FromSeconds(15)
    }
    Process
    {
        foreach ($Uri in $Url)
        {
            do
            {
                try
                {
                    #Read only headerss, don't download the file
                    $WebRequest = $HttpClient.GetAsync($Uri, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead)

                    $Response = $WebRequest.GetAwaiter().GetResult()
                }
                catch
                {
                    $Uri = $False
                    #Write-Error -Message "Could not send request to: $Uri" -ErrorAction Continue
                    Break
                }

                #Continue loop until the url matches itself
                if ($Response.RequestMessage.RequestUri.AbsoluteUri -ne $Uri)
                {
                    [string] $Uri = $Response.RequestMessage.RequestUri.AbsoluteUri
                }
                else
                {
                    $Uri = $False
                    #Write-Error -Message "Could not find download url: $Uri" -ErrorAction Continue
                    Break
                }
            }
            until ([bool] ([System.IO.Path]::GetExtension($Uri) -match 'exe$|msi$|zip$|7z$|nupkg$'))

            if ($Uri -ne $False)
            {
                [PSCustomObject]@{
                    Url = $Uri
                }
            }
        }   
    }
    End
    {
        $HttpClient.Dispose()
    }
}