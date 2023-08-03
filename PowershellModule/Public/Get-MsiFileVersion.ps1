function Get-MsiFileVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $FilePath
    )
    Begin
    {

    }
    Process
    {
        $SoftwareVersioning = Get-PSAutoDownloadRegularExpression -RegularExpression SoftwareVersioning

        $File = Get-Item -LiteralPath $FilePath
        $ShellApplication = New-Object -ComObject Shell.Application
        $ParentFolder = $ShellApplication.NameSpace( $File.DirectoryName )
        $ParseFile = $ParentFolder.ParseName( $File.Name )
        $FileSoftwareVersioning = $ParentFolder.GetDetailsOf($ParseFile, 24)
        
        [System.Text.RegularExpressions.Regex]::Match( $FileSoftwareVersioning, $SoftwareVersioning ) | Select-Object -ExpandProperty Value
    }
    End
    {

    }
}