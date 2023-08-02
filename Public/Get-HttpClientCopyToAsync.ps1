function Get-HttpClientCopyToAsync
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Threading.Tasks.Task]
        $SaveTask,

        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]
        $Destination
    )
    Begin
    {
        Add-Type -AssemblyName System.IO
    }
    Process
    {
        $FileStream = [System.IO.FileStream]::new($Destination, [System.IO.FileMode]::Create)
        $SaveTask.GetAwaiter().GetResult().CopyToAsync($FileStream)

        [PSCustomObject]@{
            SaveTask = $SaveTask
            FileStream = $FileStream
        } 
    }
    End
    {

    }
}