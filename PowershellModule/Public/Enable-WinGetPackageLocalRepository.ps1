function Enable-WinGetPackageLocalRepository
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    Param
    (
        [Parameter(Mandatory = $False)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $False)]
        [System.String]
        $Url = 'https://github.com/microsoft/winget-pkgs.git'
    )
    Begin
    {

    }
    Process
    {
        $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

        if ( $PSAutoDownloadEnvironmentVariable.WinGet -and $Path.Length -eq 0 )
        {
            $Path = $PSAutoDownloadEnvironmentVariable.WinGet
        }

        try 
        {
            $Git = Get-Command -Name git -ErrorAction Stop
        }
        catch
        {
            Write-Error -Message 'Missing git executable'
        }

        if ( Test-Path -Path $Path )
        {
            Start-Process -FilePath $Git.Source -ArgumentList 'clone', $Url, $Path -NoNewWindow -Wait
        }
    }
    End
    {
        
    }
}