function Start-PSAutoDownloadTransfer
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Url,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Destination,

        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [int]
        $ThrottleLimit = 5
    )
    Begin
    {
        Add-Type -AssemblyName System.Net.Http
        $HttpClient = [System.Net.Http.HttpClient]::new()
        $TaskManager = [System.Collections.Generic.List[Object]]::new()

        function Complete-PSAutoDownloadTask
        {
            Param ($Download)

            if ($Download.SaveTask.GetAwaiter().GetResult().NeedsDrain -eq $False)
            {
                $Download.SaveTask.Dispose()
                $Download.FileStream.Dispose()
                $TaskManager.Remove($Download) | Out-Null
            }
        }
    }
    Process
    {
        foreach ($Uri in $Url)
        {
            $StreamToReadFrom = Get-HttpClientReadAsStreamAsync -Url $Uri -HttpClient $HttpClient

            $SaveTask = Get-HttpClientCopyToAsync -SaveTask $StreamToReadFrom -Destination $Destination
            $TaskManager.Add($SaveTask)
            
            do
            {
                Start-Sleep -Milliseconds 250
                $TaskManager | ForEach-Object -Process {Complete-PSAutoDownloadTask -Download $PSItem}

            } while ($TaskManager.Count -gt $ThrottleLimit)
        }
    }
    End
    {        
        do
        {
            Start-Sleep -Milliseconds 250
            $TaskManager | ForEach-Object -Process {Complete-PSAutoDownloadTask -Download $PSItem}

        } until ($TaskManager.Count -eq 0)
        
        $HttpClient.Dispose()
    }
}