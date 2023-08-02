function Confirm-PSAutoDownloadRecipe
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]
        $File,

        [Parameter(Mandatory = $False)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        $Certificate = (Get-ChildItem Cert:\ -Recurse | Where-Object -Property FriendlyName -eq PSAutoDownload)
    )
    Begin
    {
        Add-Type -AssemblyName System.Security
    }
    Process
    {
        $XmlDocument = [System.Xml.XmlDocument]::new()
        $XmlDocument.PreserveWhitespace = $True
        $XmlDocument.Load($File)
        
        $SignedXmlDocument = [System.Security.Cryptography.Xml.SignedXml]::new($XmlDocument)
        
        $XmlNodeList = $XmlDocument.GetElementsByTagName('Signature')
        
        $SignedXmlDocument.LoadXml($XmlNodeList[0])
        
        $SignedXmlDocument.CheckSignature($Certificate, $True)
    }
    End
    {
    
    }
}