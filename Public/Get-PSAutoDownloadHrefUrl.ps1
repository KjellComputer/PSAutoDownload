function Get-PSAutoDownloadHrefUrl
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
        
        #https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-example-scanning-for-hrefs
        #$HrefRegex = "href\s*=\s*(?:[""'](?<1>[^""']*)[""']|(?<1>[^>\s]+))"
        $HrefRegex = Get-PSAutoDownloadRegex -Name href
    }
    Process
    {
        foreach ($Uri in $Url)
        {
            $Request = $HttpClient.GetAsync($Uri)

            $HtmlBody = $Request.GetAwaiter().GetResult().Content.ReadAsStringAsync().Result

            $Href = [regex]::Matches($HtmlBody, $HrefRegex, [Text.RegularExpressions.RegexOptions]::IgnoreCase)

            if ($Href)
            {
                Write-Verbose -Message "Found links on $Uri"

                foreach ($Link in $Href)
                {
                    if ($Link.Groups[1].Value -notmatch 'http|https')
                    {
                        $BaseHostUrl = '{0}://{1}' -f $Request.Result.RequestMessage.RequestUri.Scheme, $Request.Result.RequestMessage.RequestUri.Host
                        $HrefUrl = [System.Uri]::new([System.Uri]::new($BaseHostUrl), $Link.Groups[1].Value) | Select-Object -ExpandProperty AbsoluteUri
                    }
                    else
                    {
                        $HrefUrl = $Link.Groups[1].Value
                    }

                    [PSCustomObject]@{
                        Href = $HrefUrl
                    }
                }
            }
        }   
    }
    End
    {
        $HttpClient.Dispose()
    }
}