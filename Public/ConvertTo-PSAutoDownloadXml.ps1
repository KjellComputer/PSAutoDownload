function ConvertTo-PSAutoDownloadXml
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]
        $Name,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]
        $Command,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]
        $RecipeType,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String]
        $Maintainer
    )
    Begin
    {
        Add-Type -AssemblyName System.Security
        Add-Type -AssemblyName System.Xml
    }
    Process
    {
        $XmlDocument = [System.Xml.XmlDocument]::new()
        $XmlDocument.PreserveWhitespace = $True

        #Declaration
        [System.Xml.XmlDeclaration] $XmlDeclaration = $XmlDocument.CreateXmlDeclaration('1.0', 'UTF-8', $Null)
        $XmlDocument.AppendChild($XmlDeclaration) | Out-Null

        #Comment
        [System.Xml.XmlComment] $XmlComment = $XmlDocument.CreateComment('PSAutoDownload Recipe 1.0')
        $XmlDocument.AppendChild($XmlComment) | Out-Null

        #Recipe Root
        [System.Xml.XmlElement] $XmlElementRecipeRoot = $XmlDocument.CreateElement('Recipe')
        $XmlDocument.AppendChild($XmlElementRecipeRoot) | Out-Null

        #Recipe Configuration
        [System.Xml.XmlElement] $XmlElementRecipeConfiguration = $XmlElementRecipeRoot.AppendChild($XmlDocument.CreateElement('Configuration'))

        #Recipe Name
        [System.Xml.XmlElement] $XmlElementRecipeName = $XmlElementRecipeConfiguration.AppendChild($XmlDocument.CreateElement('Name'))
        $XmlElementRecipeName.InnerText = $Name

        #Recipe Command
        [System.Xml.XmlElement] $XmlElementRecipeCommand = $XmlElementRecipeConfiguration.AppendChild($XmlDocument.CreateElement('Command'))
        $XmlElementRecipeCommand.InnerText = $Command
        
        #Recipe Type
        [System.Xml.XmlElement] $XmlElementRecipeType = $XmlElementRecipeConfiguration.AppendChild($XmlDocument.CreateElement('RecipeType'))
        $XmlElementRecipeType.InnerText = $RecipeType

        #Recipe Maintainer
        [System.Xml.XmlElement] $XmlElementRecipeMaintainer = $XmlElementRecipeConfiguration.AppendChild($XmlDocument.CreateElement('Maintainer'))
        $XmlElementRecipeMaintainer.InnerText = $Maintainer

        #Return Xml object
        $XmlDocument
    }
    End
    {

    }
}