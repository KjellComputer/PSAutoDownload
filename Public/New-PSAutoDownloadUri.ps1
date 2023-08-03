function New-PSAutoDownloadUri
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $False)]
        [System.Uri[]]
        $Uri,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [System.String]
        $OutFile,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [System.String[]]
        $Extension,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [System.String[]]
        $Architecture,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [System.String[]]
        $Exclude,
        
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [System.String]
        $Recipe
    )
    Begin
    {

    }
    Process
    {
        foreach ( $PSDownloadUri in $Uri )
        {
            if ( $OutFile.Length -eq 0 )
            {
                $OutFile = [System.IO.Path]::GetFileName( $PSDownloadUri.AbsoluteUri )
                $OutFile = $OutFile -Replace '%20','_'
            }
            
            if ( $Extension )
            {
                $Extensions = ( $Extension | ForEach-Object -Process { $_.Insert( $_.Length, '$' ) } ) -join '|'
                $PSDownloadUri = $PSDownloadUri | Where-Object -FilterScript { $_.AbsoluteUri -match $Extensions }
            }

            if ( $Architecture )
            {
                $Architectures = $Architecture -join '|'
                $PSDownloadUri = $PSDownloadUri | Where-Object -FilterScript { $_.AbsoluteUri -match $Architectures }
            }
             
            if ( $Exclude )
            {
                $Excludes = $Exclude -join '|'
                $PSDownloadUri = $PSDownloadUri | Where-Object -FilterScript { $_.AbsoluteUri -notmatch $Excludes }
            }

            if ( $PSDownloadUri )
            {
                [PSCustomObject]@{
                    OutFile = $OutFile
                    Uri     = $PSDownloadUri
                    Recipe  = $Recipe
                }
            }
        }        
    }
    End
    {

    }
}