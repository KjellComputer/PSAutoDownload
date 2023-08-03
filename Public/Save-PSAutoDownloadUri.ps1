function Save-PSAutoDownloadUri
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [System.Uri[]]
        $Uri,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [System.String]
        $OutFile,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [System.String]
        $Recipe,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [System.String]
        $Type
    )
    Begin
    {

    }
    Process
    {
        $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

        foreach ( $PSDownloadUri in $Uri )
        {
            switch ( $Type )
            {
                'Application'
                {
                    $Path = $PSAutoDownloadEnvironmentVariable.Applications
                }
            
                'PowershellGallery'
                {
                    $Path = $PSAutoDownloadEnvironmentVariable.PSModules
                    $Nuget = $True
                }
            }
            
            $Destination = Join-Path -Path $Path -ChildPath $Recipe.Substring(0,1)
            $Destination = Join-Path -Path $Destination -ChildPath $Recipe

            if ( -not ( Test-Path -LiteralPath $Destination ) )
            {
                New-Item -Type Directory -Path $Destination
            }

            $OutFile = Join-Path -Path $Destination -ChildPath $OutFile

            Start-PSAutoDownloadTransfer -Uri $PSDownloadUri -OutFile $OutFile
        }
    }
    End
    {

    }
}