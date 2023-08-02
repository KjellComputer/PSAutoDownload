function Invoke-PSAutoDownload
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $False)]
        [String]
        $Path,

        [Parameter(Mandatory = $False)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate = (Get-ChildItem Cert:\ -Recurse | Where-Object -Property FriendlyName -eq PSAutoDownload)
    )
    Begin
    {
        $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

        if ($PSAutoDownloadEnvironmentVariable.Recipes -and $Path.Length -eq 0)
        {
            $Path = $PSAutoDownloadEnvironmentVariable.Recipes
        }

        $ConfigurationFiles = Get-ChildItem -LiteralPath $Path -Filter *.xml
    }
    Process
    {
        foreach ($File in $ConfigurationFiles)
        {
            $XmlDocument = [System.Xml.XmlDocument]::new()
            $XmlDocument.PreserveWhitespace = $True
            $XmlDocument.Load($File.FullName)

            if ([bool] $XmlDocument.GetElementsByTagName('Signature') -eq $False -and [bool] $XmlDocument.GetElementsByTagName('EncryptedData') -eq $False)
            {
                Write-Warning "$($File.FullName) is not protected"
                Break
            }

            if ([bool] $XmlDocument.GetElementsByTagName('Signature') -and $Certificate)
            {
                try
                {
                    $ValidRecipe = Confirm-PSAutoDownloadRecipe -File $File.FullName -Certificate $Certificate
                }
                catch 
                {
                    Write-Warning -Message "Unable to validate signature in $($File.FullName)"
                    $ValidRecipe = $False
                    Break
                }
            }
            else
            {
                Write-Warning -Message "Missing certificate to validate recipe"
                $ValidRecipe = $False
                Break
            }

            if ([bool] $XmlDocument.GetElementsByTagName('EncryptedData') -and $Certificate)
            {
                try
                {
                    $Recipe = Unprotect-PSAutoDownloadRecipe -Recipe $File.FullName
                    $ValidRecipe = $True
                }
                catch 
                {
                    Write-Warning -Message "Unable to validate decrypt $($File.FullName)"
                    $ValidRecipe = $False
                    Break
                }
            }
            else
            {
                Write-Warning -Message "Missing certificate to decrypt recipe"
                $ValidRecipe = $False
                Break
            }

            if ($ValidRecipe -and $Recipe)
            {
                $ScriptBlock = [ScriptBlock]::Create("$($Recipe.Recipe.Configuration.Command) -RecipeName $($Recipe.Recipe.Configuration.Name) -RecipeType $($Recipe.Recipe.Configuration.RecipeType)")
                Invoke-Command -ScriptBlock $ScriptBlock
            }
        }
    }
    End
    {

    }
}