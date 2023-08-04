function Add-SeBatchLogonRight
{
    [CmdletBinding()]
    [OutputType([Object])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [System.String]
        $UserName,

        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [ValidateSet('LocalMachine','Domain')]
        [System.String]
        $ContextType = 'LocalMachine'
    )
    Begin
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement        
    }
    Process
    {
        if ( $ContextType -eq 'Domain' )
        
        {
            $PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new( [System.DirectoryServices.AccountManagement.ContextType]::Domain )
        }

        if ($ContextType -eq 'LocalMachine')
        {
            $PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new( [System.DirectoryServices.AccountManagement.ContextType]::Machine )
        }
        
        $UserPrincipal = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity( $PrincipalContext, $UserName )
        
        if ( $UserPrincipal.Sid )
        {
            $TempFileName = [System.IO.Path]::GetTempFileName()
            $TempFileName = $TempFileName -replace 'tmp','inf'

            $ArgumentList = '/export /areas USER_RIGHTS /cfg {0}' -f $TempFileName
            Start-Process -FilePath C:\Windows\system32\SecEdit.exe -ArgumentList $ArgumentList -NoNewWindow -Wait

            $PrivilegeRights = Get-Content -Path $TempFileName | Where-Object -FilterScript {$_ -match '='} | ConvertFrom-StringData
            $AddToSeBatchLogonRight = $PrivilegeRights.SeBatchLogonRight.Insert( $PrivilegeRights.SeBatchLogonRight.Length, ",*$($UserPrincipal.Sid.Value)" )
            $TempAddToSeBatchLogonRight = Get-Content -Path $TempFileName
            $IndexAddToSeBatchLogonRight = [System.Int32] ($TempAddToSeBatchLogonRight | Where-Object -FilterScript {$_ -match 'SeBatchLogonRight'} | Select-Object -ExpandProperty ReadCount) - 1
            $TempAddToSeBatchLogonRight[$IndexAddToSeBatchLogonRight] = ( $TempAddToSeBatchLogonRight | Where-Object -FilterScript {$_ -match 'SeBatchLogonRight'} ) -replace [regex]::Escape( $PrivilegeRights.SeBatchLogonRight ), [regex]::Escape( $AddToSeBatchLogonRight ) -replace '\\',''

            $TempAddToSeBatchLogonRight | Out-File -FilePath $TempFileName -Encoding unicode

            $ArgumentList = '/configure /db {0} /cfg {1} /areas USER_RIGHTS' -f 'secedit.sdb', $TempFileName
            Start-Process -FilePath C:\Windows\system32\SecEdit.exe -ArgumentList $ArgumentList -NoNewWindow -Wait
            Remove-Item -Path $TempFileName
        }
    }
    End
    {
        
    }
}