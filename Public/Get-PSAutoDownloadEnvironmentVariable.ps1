function Get-PSAutoDownloadEnvironmentVariable
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (

    )
    Begin
    {
        
    }
    Process
    {
        if ($env:PSAutoDownload)
        {
            $env:PSAutoDownload -split ';' | ForEach-Object -Process {ConvertFrom-StringData -StringData $_}
        }
    }
    End
    {
        
    }
}