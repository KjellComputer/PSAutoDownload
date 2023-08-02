function Get-PSAutoDownloadUrl
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias('InstallerUrl')]
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
        #[ValidateSet('preview','alpha','beta','rc','ftp','portable')]
        [String[]]
        $Exclude,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [Switch]
        $RedirectUrl,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [Switch]
        $DirectUrl,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [String]
        $RecipeName
    )
    Begin
    {
        #$ProgramVersionRegex = '(?:\%\d\d)*(\d+\.[\d\.]+\d|\d{3,4})'
        $ProgramVersionRegex = Get-PSAutoDownloadRegex -Name programversion
        #$ProgramExtensionRegex = 'exe$|msi$|zip$|7z$|nupkg$|msp$'
        $ProgramExtensionRegex = Get-PSAutoDownloadRegex -Name extensions
        $ProgramArchRegex = '(x64|x86)?'
    }
    Process
    {
        foreach ($Uri in $Url)
        {
            if ($RedirectUrl)
            {
                $PSAutoDownloadUrl = Get-PSAutoDownloadRedirectUrl -Url $Uri | Select-Object -ExpandProperty Url

                if ($PSAutoDownloadUrl)
                {
                    New-PSAutoDownloadUrl -Url $PSAutoDownloadUrl -FileName $FileName -Extension $Extension -Arch $Arch -Exclude $Exclude -RecipeName $RecipeName
                }
            }
            elseif ($DirectUrl)
            {
                New-PSAutoDownloadUrl -Url $Uri -FileName $FileName -Extension $Extension -Arch $Arch -Exclude $Exclude -RecipeName $RecipeName
            }
            else
            {
                $Urls = Get-PSAutoDownloadHrefUrl -Url $Uri | 
                    Where-Object -FilterScript {$_.Href -Match $ProgramVersionRegex -and $_.Href -match $ProgramExtensionRegex -and $_.Href -match $ProgramArchRegex} |
                    Select-Object -ExpandProperty Href

                foreach ($PSAutoDownloadUrl in $Urls)
                {
                    New-PSAutoDownloadUrl -Url $PSAutoDownloadUrl -FileName $FileName -Extension $Extension -Arch $Arch -Exclude $Exclude -RecipeName $RecipeName
                }
            }
        }
    }
    End
    {

    }
}