function New-PSAutoDownloadUrl
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $False)]
        [String[]]
        $Url,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String]
        $FileName,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String[]]
        $Extension,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String[]]
        $Arch,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String[]]
        $Exclude,
        
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [String]
        $RecipeName
    )
    Begin
    {

    }
    Process
    {
        foreach ($Uri in $Url)
        {
            if ($FileName)
            {
               $SaveFileName = $FileName
            }
            else
            {
               $SaveFileName = [System.IO.Path]::GetFileName($Uri)
               $SaveFileName = $SaveFileName -Replace '%20','_'
            }

            if ($Extension)
            {
                $Extensions = ($Extension | ForEach-Object -Process {$_.Insert($_.Length, '$')}) -join '|'
                $Uri = $Uri | Where-Object -FilterScript {$_ -match $Extensions}
            }

            if ($Arch)
            {
                $Architectures = $Arch -join '|'
                $Uri = $Uri | Where-Object -FilterScript {$_ -match $Architectures}
            }
             
            if ($Exclude)
            {
                $Excludes = $Exclude -join '|'
                $Uri = $Uri | Where-Object -FilterScript {$_ -notmatch $Excludes}
            }

            if ($Uri)
            {
                [PSCustomObject]@{
                    FileName = $SaveFileName
                    Url = $Uri
                    RecipeName = $RecipeName
                }
            }
        }        
    }
    End
    {

    }
}