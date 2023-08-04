function Update-WinGetPackageLocalRepository
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
        $Url = 'https://github.com/microsoft/winget-pkgs.git',

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter]
        $Schedule
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
            $ArgumentList = '-C {0} pull origin master' -f $Path
            Start-Process -FilePath $Git.Source -ArgumentList $ArgumentList -NoNewWindow -Wait
        }


        if ($Schedule)
        {
            $Credential = Get-Credential -Message 'Service Account for PSAutoDownload'            
            
            $ScheduledTaskAction = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "Import-Module -Name PSAutoDownload; Update-WinGetPackageLocalRepository"'
            $ScheduledTaskTrigger = New-ScheduledTaskTrigger -Once -At ( Get-Date ) -RepetitionInterval ( New-TimeSpan -Minutes 30 )
            Register-ScheduledTask -TaskName 'Update-WinGetPackageLocalRepository' -Action $ScheduledTaskAction -Trigger $ScheduledTaskTrigger -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password
        }
    }
    End
    {
        
    }
}