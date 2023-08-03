function Unprotect-PSAutoDownloadRecipe
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [System.String]
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