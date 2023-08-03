function New-PSAutoDownloadRecipe
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [String]
        $Name,
        
        [Parameter(Mandatory = $False)]
        [String]
        $Command = $Null,
        
        [Parameter(Mandatory = $True)]
        [ValidateSet('PowerShellGallery','Application')]
        $RecipeType,
        
        [Parameter(Mandatory = $False)]
        [String]
        $Path,

        [Parameter(Mandatory = $False)]
        [Switch]
        $Base64Command = $False,

        [Parameter(Mandatory = $False)]
        [String]
        $Maintainer,

        [Parameter(Mandatory = $False)]
        [Switch]
        $Encrypted,

        [Parameter(Mandatory = $False)]
        $Certificate = (Get-ChildItem Cert:\ -Recurse | Where-Object -Property FriendlyName -eq PSAutoDownload)
    )
    Begin
    {

    }
    Process
    {
        $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

        if ($PSAutoDownloadEnvironmentVariable.Approval -and $Path.Length -eq 0)
        {
            $Path = $PSAutoDownloadEnvironmentVariable.Approval
        }

        $Path = '{0}\{1}.xml' -f $Path, $Name

        if (Test-Path -LiteralPath $Path)
        {
            Write-Error -Message "$Path already exists" -ErrorAction Stop
        }
        
        if ($Maintainer)
        {
            #[System.Net.Mail.MailAddress]::new($Maintainer)
        }

        $PSAutoRecipe = [PSCustomObject]@{
            Name = $Name
            Command = $Command
            RecipeType = $RecipeType
            Maintainer = $Maintainer
        } | ConvertTo-PSAutoDownloadXml
        # | Export-CliXML -Path $Path

        $PSAutoRecipe.Save($Path)

        if ($Encrypted)
        {
            if ($Certificate.GetType() -eq [System.String])
            {
                $EncryptionCertificate = Get-ChildItem Cert:\ -Recurse | Where-Object -FilterScript {$_ -match $Certificate} | Select-Object -First 1
            }
            elseif ($Certificate.GetType() -eq [System.Security.Cryptography.X509Certificates.X509Certificate2])
            {
                $EncryptionCertificate = $Certificate
            }

            if ($EncryptionCertificate)
            {
                try
                {
                    Protect-PSAutoDownloadRecipe -Recipe $Path -Certificate $EncryptionCertificate
                }
                catch
                {
                    Write-Error -Message "Unable to encrypt $Path"
                }
            }
            else
            {
                Write-Warning -Message "Unable to encrypt $Path, missing valid certificate: $Certificate"
            }
        }
    }
    End
    {
        
    }
}