function Approve-PSAutoDownloadRecipe
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
        [String]
        $Path,

        [Parameter(Mandatory = $False)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate = (Get-ChildItem Cert:\ -Recurse | Where-Object -Property FriendlyName -eq PSAutoDownload)
    )
    Begin
    {
        Add-Type -AssemblyName System.Security
        
        $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

        if ($PSAutoDownloadEnvironmentVariable.Approval -and $Path.Length -eq 0)
        {
            $Path = $PSAutoDownloadEnvironmentVariable.Approval
        }
    }
    Process
    {
        foreach ($Recipe in (Get-ChildItem -LiteralPath $Path -Filter '*.xml'))
        {
            if (Test-Path -LiteralPath ('{0}\Processed\{1}' -f $Recipe.Directory.Parent.FullName, $Recipe.Name))
            {
                $Recipe | Move-Item -Destination ('{0}\Discarded\{1}{2}' -f $Recipe.Directory.Parent.FullName, (Get-Date).ToString('yyyy-MM-dd-HHmm-'), $Recipe.Name)
                Write-Verbose -Message "$($Recipe.FullName) was discaded because another recipe is active with same name."
            }
            else
            {
                try
                {
                    #$Recipe
                    $SignedXmlFile = $Recipe.Name
                    $SignedXmlFile = '{0}\Recipes\{1}' -f $Recipe.Directory.Parent.FullName, $SignedXmlFile.Insert($SignedXmlFile.IndexOf($Recipe.Extension),'_Signed')
                }
                catch
                {
                    Write-Error "Could not load $Recipe" -ErrorAction Stop
                }

                $XmlDocument = [System.Xml.XmlDocument]::new()
                $XmlDocument.PreserveWhitespace = $True
                $XmlDocument.Load($Recipe.FullName)
                
                $SignedXmlDocument = [System.Security.Cryptography.Xml.SignedXml]::new($XmlDocument)
                $SignedXmlDocument.SigningKey = $Certificate.PrivateKey
                
                $Reference = [System.Security.Cryptography.Xml.Reference]::new()
                $Reference.Uri = ""
                
                $XmlDsigEnvelopedSignatureTransform = [System.Security.Cryptography.Xml.XmlDsigEnvelopedSignatureTransform]::new()
                
                $Reference.AddTransform($XmlDsigEnvelopedSignatureTransform)
                
                $SignedXmlDocument.AddReference($Reference)
                
                $SignedXmlDocument.ComputeSignature()
                
                $XmlDigitalSignature = $SignedXmlDocument.GetXml()
                
                $XmlDocument.DocumentElement.AppendChild($XmlDocument.ImportNode($XmlDigitalSignature, $True))
                
                $XmlDocument.Save($SignedXmlFile)

                $Recipe | Move-Item -Destination ('{0}\Processed\' -f $Recipe.Directory.Parent.FullName)
            }
        }
    }
    End
    {
    
    }
}