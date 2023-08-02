function Initialize-PSAutoDownloadRepository
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True)]
        [String]
        $Path,

        [Parameter(Mandatory = $False)]
        [Switch]
        $Force,

        [Parameter(Mandatory = $False)]
        [ValidateSet('5.1','7')]
        [string]
        $SchedulePSAutoDownload = $False
    )
    Begin
    {
        if ($env:PSAutoDownload -and $Force -eq $False)
        {
            Write-Error -Message 'Environment variable PSAutoDownload already exists, force re-initialization with -Force switch' -ErrorAction Stop 
        }
    }
    Process
    { 
        if (-not(Test-Path -LiteralPath $Path\PSAutoDownloadRepository) -or $Force -eq $True)
        {
            New-Item -Path $Path\PSAutoDownloadRepository -ItemType Directory -Force
            New-Item -Path $Path\PSAutoDownloadRepository\Log -ItemType Directory -Force
            New-Item -Path $Path\PSAutoDownloadRepository\Recipes -ItemType Directory -Force
            New-Item -Path $Path\PSAutoDownloadRepository\Processed -ItemType Directory -Force
            New-Item -Path $Path\PSAutoDownloadRepository\Discarded -ItemType Directory -Force
            New-Item -Path $Path\PSAutoDownloadRepository\Approval -ItemType Directory -Force
            New-Item -Path $Path\PSAutoDownloadRepository\PSModules -ItemType Directory -Force
            New-Item -Path $Path\PSAutoDownloadRepository\Applications -ItemType Directory -Force
            New-Item -Path $Path\PSAutoDownloadRepository\WinGet -ItemType Directory -Force

            $PSAuto = Get-ChildItem -LiteralPath $Path\PSAutoDownloadRepository -Directory | ForEach-Object -Process {'{0}={1}' -f $_.Name, $_.FullName}
            $PSAuto = $PSAuto -join ';'
            $PSAuto = $PSAuto -replace '\\','\\'
            
            if ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')
            {
                [System.Environment]::SetEnvironmentVariable('PSAutoDownload', $PSAuto, 'Machine')

                if ($SchedulePSAutoDownload)
                {
                    $Credential = Get-Credential -Message 'Service Account for PSAutoDownload'

                    $Acl = Get-Acl -LiteralPath $Path\PSAutoDownloadRepository
                    $FileSystemAccessRule = [System.Security.AccessControl.FileSystemAccessRule]::new($Credential.UserName, "Modify", "ContainerInherit,ObjectInherit", "InheritOnly", "Allow")

                    $Acl.SetAccessRule($FileSystemAccessRule)
                    $Acl | Set-Acl -LiteralPath $Path\PSAutoDownloadRepository

                    Add-SeBatchLogonRight -UserName $Credential.UserName -ContextType Domain

                    if ($SchedulePSAutoDownload -eq '5.1')
                    {
                        $ScheduledTaskAction = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "Import-Module -Name PSAutoDownload; Approve-PSAutoDownloadRecipe"'
                        $ScheduledTaskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 120)
                        Register-ScheduledTask -TaskName 'Approve-PSAutoDownloadRecipe' -Action $ScheduledTaskAction -Trigger $ScheduledTaskTrigger -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password

                        $ScheduledTaskAction = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "Import-Module -Name PSAutoDownload; Invoke-PSAutoDownload"'
                        $ScheduledTaskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10)
                        Register-ScheduledTask -TaskName 'Invoke-PSAutoDownload' -Action $ScheduledTaskAction -Trigger $ScheduledTaskTrigger -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password
                    }
                    else 
                    {
                        $ScheduledTaskAction = New-ScheduledTaskAction -Execute 'C:\Program Files\PowerShell\7\pwsh.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "Import-Module -Name PSAutoDownload; Approve-PSAutoDownloadRecipe"'
                        $ScheduledTaskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 120)
                        Register-ScheduledTask -TaskName 'Approve-PSAutoDownloadRecipe' -Action $ScheduledTaskAction -Trigger $ScheduledTaskTrigger -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password

                        $ScheduledTaskAction = New-ScheduledTaskAction -Execute 'C:\Program Files\PowerShell\7\pwsh.exe' -Argument '-NoProfile -WindowStyle Hidden -Command "Import-Module -Name PSAutoDownload; Invoke-PSAutoDownload -Parallel 10"'
                        $ScheduledTaskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10)
                        Register-ScheduledTask -TaskName 'Invoke-PSAutoDownload' -Action $ScheduledTaskAction -Trigger $ScheduledTaskTrigger -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password
                    }


                }
            }
            else
            {
                Write-Warning -Message '$env:PSAutoDownload will only be available in this session, run function as administrator to make it persistent'
                [System.Environment]::SetEnvironmentVariable('PSAutoDownload', $PSAuto)
            }
        }
        else
        {
            Write-Error "PSAutoDownload already initialized at $Path" -ErrorAction Stop
        }
    }
    End
    {
    
    }
}