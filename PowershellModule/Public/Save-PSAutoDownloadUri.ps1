function Save-PSAutoDownloadUri
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [System.Uri]
        $Uri,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
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
        $Skip = $False,

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
            if ( $Skip -eq $False )
            {
                $ReferenceFileHash = Get-FileHash -Path $OutFile -Algorithm SHA256
                $OutFile = $OutFile.Replace( [System.IO.Path]::GetExtension( $OutFile ), [System.IO.Path]::GetExtension( $OutFile ).Insert( 0 , '-psautodownload' ) )

                $VerifyFileHash = $True
                Write-Information -MessageData "Existing $OutFile, verifying file hash..." -InformationAction Continue
            }
            else
            {
                # If we know that downloaded files will have unique names, don't bother downloading them again if outfile exists with the Save-PSAutoDownloadUri -Skip parameter
                # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_continue?view=powershell-7.3
                # The continue statement provides a way to exit the current control block but continue execution, rather than exit completely. 

                Continue
            }
        }

        # Begin downloading the file
        # This needs better error handling later on, like failed downloads or urls that don't exists anymore when using Get-PSAutoDownload -DirectUrl parameter
        Start-PSAutoDownloadTransfer -Uri $Uri -OutFile $OutFile

        if ( $VerifyFileHash -eq $True )
        {
            $DifferenceFileHash = Get-FileHash -Path $OutFile -Algorithm SHA256

            if ( $ReferenceFileHash.Hash -eq $DifferenceFileHash.Hash )
            {
                Remove-Item -LiteralPath $OutFile
                Write-Information -MessageData "$OutFile removed..." -InformationAction Continue
            }
            else
            {
                $NewName = [System.IO.Path]::GetFileName( $OutFile ).Replace( 'psautodownload', (Get-Date).ToString('yyyy-MM-dd') )
            }
        }
            
        if ( $TryParseSoftwareVersioning )
        {
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
                            $NewName = [System.IO.Path]::GetFileName( $OutFile ).Replace( [System.IO.Path]::GetExtension( $OutFile ), [System.IO.Path]::GetExtension( $OutFile ).Insert( 0 , "-$($FileVersion)" ) )
                        }
                    }
                    catch
                    {
                        Write-Information -MessageData "Parsing fileversion failed, defaulting to date scheme..." -InformationAction Continue
                    }
                }
            }
        }

        if ( ( Test-Path -LiteralPath $OutFile ) -and $NewName )
        {
            if ( Get-ChildItem -LiteralPath (Get-Item -LiteralPath $OutFile).Directory -Filter $NewName | Test-Path )
            {
                Remove-Item -LiteralPath $OutFile
                Write-Information -MessageData "$OutFile removed, already exists..." -InformationAction Continue
            }
            else
            {
                Rename-Item -LiteralPath $OutFile -NewName $NewName
            }
        }
    }
    End
    {

    }
}