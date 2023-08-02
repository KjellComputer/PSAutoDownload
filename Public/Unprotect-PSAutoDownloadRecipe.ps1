function Unprotect-PSAutoDownloadRecipe
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [String]
        $Recipe
    )
    Begin
    {
        Add-Type -AssemblyName System.Security
    }
    Process
    {
        $XmlDocument = [System.Xml.XmlDocument]::new()
        $XmlDocument.PreserveWhitespace = $True
        $XmlDocument.Load($Recipe)

        $EncryptedXml = [System.Security.Cryptography.Xml.EncryptedXml]::new($XmlDocument)
        $EncryptedXml.DecryptDocument()

        #Return the decrypted XML object
        $XmlDocument
    }
    End
    {
        
    }
}