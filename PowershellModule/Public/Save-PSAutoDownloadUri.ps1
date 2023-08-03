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
        $Type,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter]
        $TryParseSoftwareVersioning = $False
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

            if ( Test-Path -LiteralPath $OutFile )
            {
                $ReferenceFileHash = Get-FileHash -Path $OutFile -Algorithm SHA256
                $OutFile = $OutFile.Replace( [System.IO.Path]::GetExtension( $OutFile ), [System.IO.Path]::GetExtension( $OutFile ).Insert( 0 , '-psautodownload' ) )

                $VerifyFileHash = $True
            }

            if ( $TryParseSoftwareVersioning )
            {
                $OutFile = $OutFile.Replace( [System.IO.Path]::GetExtension( $OutFile ), [System.IO.Path]::GetExtension( $OutFile ).Insert( 0 , '-psautodownload' ) )
            }

            Start-PSAutoDownloadTransfer -Uri $PSDownloadUri -OutFile $OutFile

            if ( $VerifyFileHash -eq $True )
            {
                $DifferenceFileHash = Get-FileHash -Path $OutFile -Algorithm SHA256

                if ( $ReferenceFileHash.Hash -eq $DifferenceFileHash.Hash )
                {
                    Remove-Item -LiteralPath $OutFile
                }
                else
                {
                    $NewName = [System.IO.Path]::GetFileName( $OutFile ).Replace( 'psautodownload', (Get-Date).ToString('yyyy-MM-dd') )
                }
            }
                
            if ( $TryParseSoftwareVersioning )
            {
                $NewName = [System.IO.Path]::GetFileName( $OutFile ).Replace( 'psautodownload', (Get-Date).ToString('yyyy-MM-dd') )

                switch ( [System.IO.Path]::GetExtension( $OutFile ) )
                {
                    '.exe'
                    {
                        try
                        {
                            $VersionInfo = Get-Item -LiteralPath $OutFile | Select-Object -Property VersionInfo
                            
                            if ( $VersionInfo.VersionInfo.FileVersion )
                            {
                                $NewName = [System.IO.Path]::GetFileName( $OutFile ).Replace( 'psautodownload', $VersionInfo.VersionInfo.FileVersion )
                            }
                        }
                        catch
                        {
                            Write-Information -MessageData "Parsing fileversion failed, defaulting to date scheme..." -InformationAction Continue
                        }
                    }
                    '.msi'
                    {
                        try
                        {
                            $FileVersion = Get-MsiFileVersion -FilePath $OutFile

                            if ( $FileVersion )
                            {
                                $NewName = [System.IO.Path]::GetFileName( $OutFile ).Replace( 'psautodownload', $FileVersion )
                            }
                        }
                        catch
                        {
                            Write-Information -MessageData "Parsing fileversion failed, defaulting to date scheme..." -InformationAction Continue
                        }
                    }
                }
            }
                
            if ( Test-Path -LiteralPath $OutFile )
            {
                Rename-Item -LiteralPath $OutFile -NewName $NewName
            }
        }
    }
    End
    {

    }
}