function Approve-PSAutoDownloadRecipe
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $False)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate = ( Get-ChildItem Cert:\ -Recurse | Where-Object -Property FriendlyName -eq PSAutoDownload )
    )
    Begin
    {
        Add-Type -AssemblyName System.Security
    }
    Process
    {
                
        $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

        if ( $PSAutoDownloadEnvironmentVariable.Approval -and $Path.Length -eq 0 )
        {
            $Path = $PSAutoDownloadEnvironmentVariable.Approval
        }

        foreach ( $Recipe in ( Get-ChildItem -LiteralPath $Path -Filter '*.xml' ) )
        {
            $ProcessedRecipe = Join-Path -Path $Recipe.Directory.Parent.FullName -ChildPath Processed -AdditionalChildPath $Recipe.Name
            
            if ( Test-Path -LiteralPath $ProcessedRecipe )
            {
                $DiscardedRecipe = Join-Path $Recipe.Directory.Parent.FullName -ChildPath Discarded -AdditionalChildPath ( (Get-Date).ToString( 'yyyy-MM-dd-HHmm' ), $Recipe.Name -join '-' )
                
                $Recipe | Move-Item -Destination $DiscardedRecipe
                Write-Verbose -Message "$($Recipe.FullName) was discaded because another recipe is active with same name."
            }
            else
            {
                $SignedXmlFile = Join-Path -Path $Recipe.Directory.Parent.FullName -ChildPath Recipes -AdditionalChildPath ( $Recipe.Name ).Insert( ($Recipe.Name ).IndexOf( $Recipe.Extension ),'_Signed' )

                $XmlDocument = [System.Xml.XmlDocument]::new()
                $XmlDocument.PreserveWhitespace = $True
                $XmlDocument.Load( $Recipe.FullName )
                
                $SignedXmlDocument = [System.Security.Cryptography.Xml.SignedXml]::new( $XmlDocument )
                $SignedXmlDocument.SigningKey = $Certificate.PrivateKey
                
                $Reference = [System.Security.Cryptography.Xml.Reference]::new()
                $Reference.Uri = ""
                
                $XmlDsigEnvelopedSignatureTransform = [System.Security.Cryptography.Xml.XmlDsigEnvelopedSignatureTransform]::new()
                
                $Reference.AddTransform( $XmlDsigEnvelopedSignatureTransform )
                
                $SignedXmlDocument.AddReference( $Reference )
                
                $SignedXmlDocument.ComputeSignature()
                
                $XmlDigitalSignature = $SignedXmlDocument.GetXml()
                
                $XmlDocument.DocumentElement.AppendChild( $XmlDocument.ImportNode( $XmlDigitalSignature, $True ) )
                
                $XmlDocument.Save( $SignedXmlFile )

                $MoveProcessedRecipe = Join-Path -Path $Recipe.Directory.Parent.FullName -ChildPath Processed
                $Recipe | Move-Item -Destination $MoveProcessedRecipe
            }
        }
    }
    End
    {
    
    }
}