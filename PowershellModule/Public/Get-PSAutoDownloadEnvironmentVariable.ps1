function Get-PSAutoDownloadEnvironmentVariable
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param
    (

    )
    Begin
    {
        
    }
    Process
    {
        if ( $env:PSAutoDownload )
        {
            $env:PSAutoDownload -split ';' | ForEach-Object -Process { ConvertFrom-StringData -StringData $_ }
        }
        else
        {
            Write-Warning -Message 'No $env:PSAutoDownload available, run Initialize-PSAutoDownloadRepository first...'
        }
    }
    End
    {
        
    }
}