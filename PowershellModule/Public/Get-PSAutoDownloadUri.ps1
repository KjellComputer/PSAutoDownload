function Get-PSAutoDownloadUri
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias()]
        [System.String]
        $Url,

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
        #[ValidateSet('preview','alpha','beta','rc','ftp','portable')]
        [System.String[]]
        $Exclude,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [System.Management.Automation.SwitchParameter]
        $RedirectUrl,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [System.Management.Automation.SwitchParameter]
        $DirectUrl,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [System.String]
        $Recipe
    )
    Begin
    {

    }
    Process
    {
        $SoftwareVersioning = Get-PSAutoDownloadRegularExpression -RegularExpression SoftwareVersioning
        $Extensions = Get-PSAutoDownloadRegularExpression -RegularExpression Extensions
        $Architectures = Get-PSAutoDownloadRegularExpression -RegularExpression Architectures

        if ( $RedirectUrl )
        {
            $Uri = Get-PSAutoDownloadRedirectUri -Url $Url

            if ( $Uri -is [System.Uri] )
            {
                New-PSAutoDownloadUri -Uri $Uri -OutFile $OutFile -Extension $Extension -Architecture $Architecture -Exclude $Exclude -Recipe $Recipe
            }
        }       
        elseif ( $DirectUrl )
        {
            New-PSAutoDownloadUri -Uri ( [System.Uri] $Url ) -OutFile $OutFile -Extension $Extension -Architecture $Architecture -Exclude $Exclude -Recipe $Recipe
        }
        else
        {
            $Uris = Get-PSAutoDownloadHypertextReferenceUri -Url $Url

            if ( $Uris[0] -is [System.Uri] )
            {
                $Uris = $Uris.Where( { $_.AbsoluteUri -match $SoftwareVersioning -and $_.AbsoluteUri -match $Extensions -and $_.AbsoluteUri -match $Architectures } )

                foreach ($Uri in $Uris)
                {
                    New-PSAutoDownloadUri -Uri $Uri -Extension $Extension -Architecture $Architecture -Exclude $Exclude -Recipe $Recipe
                }
            }
        }
    }
    End
    {

    }
}