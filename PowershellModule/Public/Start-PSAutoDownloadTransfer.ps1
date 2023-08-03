function Start-PSAutoDownloadTransfer
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Uri[]]
        $Uri,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OutFile
    )
    Begin
    {

    }
    Process
    {
        foreach ( $PSDownloadUri in $Uri )
        {
            try
            {
                Invoke-WebRequest -Method Get -Uri $PSDownloadUri -OutFile $OutFile -ErrorAction Stop
            }
            catch
            {
                Write-Error -Message $_.Exception.Response
            }
        }
    }
    End
    {

    }
}