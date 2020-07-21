using namespace Microsoft.Azure.Storage
function New-FunStorageQueueMessage {
    [CmdletBinding()]
    param (
        
        [parameter(
            HelpMessage="Data to have in message"
        )]
        [object[]]$Data,

        [parameter(
            HelpMessage="is data Base64 encoded?"
        )]
        [Switch]$Isbase64Encoded,

        [parameter(
            HelpMessage='{Queue}'
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueue]$Queue,

        <#
                    HelpMessage = "[String] or [Timespan].
            How long do you want the message to be present in the queue?
            String should follow protocoll: '-1' = infinity, '1' = 1 day, '1:0' = 1 hour, '0:1' = 1 minute, '0:0:1' = 1 second",
        #>
        [parameter(
            HelpMessage='
            {Timespan.types}
            How long do you want the message to be present in the queue?
            {Timespan.protocoll}
            '
        )]
        [timespan]$TimeToLive = [timespan]::FromDays(7),

        [parameter(
            HelpMessage='
            {Timespan.types}
            interval of time from now during which the message will be invisible in queue
            {Timespan.protocoll}
            '
        )]
        [timespan]$InitialVisibilityDelay = [timespan]::Zero,

        [switch]$Async,
        [int]$AsyncMaxWait = 10000
    )
    
    begin {
        
    }
    process {
        $Message = [Queue.CloudQueueMessage]::new($($data -join ''),$Isbase64Encoded.IsPresent)
        Write-Verbose "Message is: $($message|ConvertTo-Json)"

        $AsyncPut = $Queue.AddMessageAsync($Message,$TimeToLive,$InitialVisibilityDelay,$null,$null)
        if(!$Async)
        {
            [void]($AsyncPut.Wait([timespan]::FromMilliseconds(200)))
            $timer = get-date
            while($AsyncPut.IsCompleted -eq $false)
            {
                Write-debug "Waiting for task to complete"
                [void]($AsyncPut.Wait([timespan]::FromMilliseconds(200)))
                if((get-date).AddMilliseconds(([math]::Abs($AsyncMaxWait)*-1)) -gt $timer)
                {
                    throw "Waited over $([timespan]::FromMilliseconds([math]::Abs($AsyncMaxWait)).TotalSeconds) seconds for message to send."
                }
            }
        }
    }
    end {}
}
