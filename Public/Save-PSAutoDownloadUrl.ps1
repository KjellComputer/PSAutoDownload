function Save-PSAutoDownloadUrl
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String[]]
        $Url,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        $Path,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [String]
        $FileName,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String]
        $JobName,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [String]
        $RecipeName,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [String]
        $RecipeType,

        [Parameter(Mandatory = $False)]
        [Switch]
        $InvokePSAutoDownload,

        [Parameter(Mandatory = $False)]
        [Int]
        $Parallel = $False
    )
    Begin
    {
        $ParallelJobs = [System.Collections.Generic.List[object]]::new()
        $DownloadJobs = [System.Collections.Generic.List[object]]::new()
    }
    Process
    {
        foreach ($Uri in $Url)
        {
            if ($InvokePSAutoDownload)
            {
                #Path for PSAutoEnvironments
                $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

                switch ($RecipeType)
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

                $Destination = Join-Path -Path $Path -ChildPath $RecipeName.Substring(0,1)
                $Destination = Join-Path -Path $Destination -ChildPath $RecipeName

                if (-not(Test-Path -LiteralPath $Destination))
                {
                    New-Item -Type Directory -Path $Destination
                }

                $Destination = Join-Path -Path $Destination -ChildPath $FileName
            }
            else 
            {
                if ($Path.Length -eq 0)
                {
                    $Path = Get-Location
                }
            
                $Destination = Join-Path -Path $Path -ChildPath $FileName
            }
            
            if ($Parallel)
            {
                $ParallelJob = [PSCustomObject]@{
                    Url = $Uri
                    Destination = $Destination
                }

                $ParallelJobs.Add($ParallelJob)
            }
            else
            {
                if (-not(Test-Path -LiteralPath $Destination))
                {
                    #Write-Verbose -Message ('Starting download for {0}' -f $FileName)
                    #Start-PSAutoDownloadTransfer2 -Url $Uri -Destination $Destination
                    $DownloadJob = [PSCustomObject]@{
                        Url = $Uri
                        Destination = $Destination
                    }

                    $DownloadJobs.Add($DownloadJob)
                    # -Asynchronous -DisplayName ('PSAutoDownload {0}' -f $DownloadUrl.FileName)
                }
            }
        }   
    }
    End
    {
        if ($ParallelJobs.Count -ge 1)
        {
            Write-Verbose "Starting download"
            $ParallelJobs | ForEach-Object -Parallel {
                    Import-Module -Name PSAutoDownload
                    if (-not(Test-Path -LiteralPath $_.Destination))
                    {
                        Start-PSAutoDownloadTransfer -Url $_.Url -Destination $_.Destination
                    }
                } -ThrottleLimit $Parallel
        }

        if ($DownloadJobs.Count -ge 1)
        {
            $DownloadJobs | Start-PSAutoDownloadTransfer
        }
    }
}