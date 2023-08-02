function Get-Something
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject[]]
        $PSObject,

        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String[]]
        $AnyExclude,

        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String[]]
        $AnyInclude
    )
    Begin
    {

    }
    Process
    {
        foreach ($Object in $PSObject)
        {
            $Excluded = $False

            $AnyExcludes = $AnyExclude -join '|'
            $AnyIncludes = $AnyInclude -join '|'

            $NoteProperties = $PSObject | Get-Member -Type NoteProperty

            foreach ($NoteProperty in $NoteProperties.Name)
            {
                if ($Object.$NoteProperty -match $AnyIncludes)
                {
                    $Excluded = $False
                    Break
                }
                elseif ($Object.$NoteProperty -match $AnyExcludes)
                {
                    $Excluded = $True
                    Break
                }
                else 
                {
                    $Excluded = $True
                }
            }
            
            if ($Excluded -eq $False)
            {
                $Object
            }
        }        
    }
    End
    {

    }
}