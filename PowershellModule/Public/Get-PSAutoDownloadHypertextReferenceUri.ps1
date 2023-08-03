function Get-PSAutoDownloadHypertextReferenceUri
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

    }
    Process
    {
        $HypertextReferenceRegex = Get-PSAutoDownloadRegularExpression -RegularExpression HypertextReference
        
        foreach ($Uri in $Url)
        {
            try
            {
                $Request = Invoke-WebRequest -Method Get -Uri $Uri -ErrorAction Stop
            }
            catch
            {
                Write-Error -Message $_.Exception.Response
            }

            if ( $Request.StatusCode -eq 200 )
            {
                $HypertextReferences = [System.Text.RegularExpressions.Regex]::Matches($Request.Content, $HypertextReferenceRegex, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
                $RequestUri = $Request.BaseResponse.RequestMessage.RequestUri

                foreach ( $HypertextReference in $HypertextReferences )
                {
                    if ( $HypertextReference.Groups[1].Value -notmatch 'http|https' )
                    {
                        $HypertextReferenceUri = [System.UriBuilder]::new( $RequestUri.Scheme, $RequestUri.Host, $RequestUri.Port, $HypertextReference.Groups[1].Value ) | Select-Object -ExpandProperty Uri
                    }
                    else
                    {
                        [System.Uri] $HypertextReferenceUri = $HypertextReference.Groups[1].Value
                    }

                    if ( $HypertextReferenceUri -is [System.Uri] )
                    {
                        $HypertextReferenceUri
                    }
                }
            }
        }   
    }
    End
    {

    }
}