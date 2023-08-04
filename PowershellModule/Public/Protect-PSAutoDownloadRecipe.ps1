function Protect-PSAutoDownloadRecipe
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [System.String]
        $Recipe,

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
        $XmlDocument = [System.Xml.XmlDocument]::new()
        $XmlDocument.PreserveWhitespace = $True
        $XmlDocument.Load( $Recipe )

        $EncryptedXml = [System.Security.Cryptography.Xml.EncryptedXml]::new()
        
        [System.Xml.XmlElement] $XmlElementToEncrypt = $XmlDocument.Recipe.Configuration

        [System.Security.Cryptography.Xml.EncryptedData] $EncryptedXmlData = $EncryptedXml.Encrypt( $XmlElementToEncrypt, $Certificate )

        [System.Security.Cryptography.Xml.EncryptedXml]::ReplaceElement( $XmlElementToEncrypt, $EncryptedXmlData, $False )

        $XmlDocument.Save( $Recipe )
    }
    End
    {
        
    }
}