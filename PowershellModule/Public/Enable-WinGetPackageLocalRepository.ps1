function Enable-WinGetPackageLocalRepository
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $False)]
        [String]
        $Path,

        [Parameter(Mandatory = $False)]
        [String]
        $Url = 'https://github.com/microsoft/winget-pkgs.git'
    )
    Begin
    {
        $PSAutoDownloadEnvironmentVariable = Get-PSAutoDownloadEnvironmentVariable

        if ($PSAutoDownloadEnvironmentVariable.WinGet -and $Path.Length -eq 0)
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
    }
    Process
    {
        if (Test-Path -Path $Path)
        {
            $ArgumentList = 'clone {0} {1}' -f $Url, $Path
            Start-Process -FilePath $Git.Source -ArgumentList $ArgumentList -NoNewWindow -Wait
        }
    }
    End
    {
        
    }
}