function Get-PSAutoDownloadRedirectUri
{
    [CmdletBinding()]
    [OutputType([System.Uri])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $Url
    )
    Begin
    {
        Add-Type -AssemblyName System.Net.Http
    }
    Process
    {
        $HttpClient = [System.Net.Http.HttpClient]::new()
        $HttpClient.Timeout = [System.TimeSpan]::FromSeconds(15)

        foreach ( $Uri in $Url )
        {
            do
            {
                try
                {
                    #Read only headerss, don't download the file
                    $WebRequest = $HttpClient.GetAsync( $Uri, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead )

                    $Response = $WebRequest.GetAwaiter().GetResult()
                }
                catch
                {
                    $Uri = $False
                    Break
                }

                #Continue loop until the url matches itself
                if ( $Response.RequestMessage.RequestUri.AbsoluteUri -ne $Uri )
                {
                    [System.String] $Uri = $Response.RequestMessage.RequestUri.AbsoluteUri
                }
                else
                {
                    $Uri = $False
                    Break
                }
            }
            until ( [System.Boolean] ( [System.IO.Path]::GetExtension( $Uri ) -match ( Get-PSAutoDownloadRegularExpression -RegularExpression Extensions ) ) )

            if ( $Uri -ne $False )
            {
                [System.Uri] $Uri
            }
        }   
    }
    End
    {
        $HttpClient.Dispose()
    }
}