
function Get-FunStorageQueueMessage {
    [CmdletBinding(DefaultParameterSetName="Get")]
    [outputtype([Microsoft.Azure.Storage.Queue.CloudQueueMessage])]
    param (

        [parameter(HelpMessage="Az storage queue",Mandatory, ValueFromPipeline)]
        [Microsoft.Azure.Storage.Queue.CloudQueue]$Queue,

        [parameter(HelpMessage="How many messages to get")]
        [ValidateRange(1,32)]
        [int]$count = 32,

        [parameter(ParameterSetName="Peek",
        HelpMessage="
        If set, it will only look at message, but not hide message for others to look at.
        ")]
        [switch]$Peek,

        [parameter(ParameterSetName="Get",
        HelpMessage = "
        String or Timespan.
        String follows following protocoll:
        1 = 1 day
        1:0 = 1 hour
        0:1 = 1 minute
        0:0:1 = 1 second
        ")]
        [timespan]$VisibilityTimeout
    )
    
    begin {
        if(![string]::IsNullOrEmpty($VisibilityTimeout))
        {
            if($VisibilityTimeout -is [timespan])
            {

            }
            elseif($VisibilityTimeout -is [string])
            {
                [timespan]::Parse($VisibilityTimeout)
            }
            else {
                Throw "Input type is not string or timespan: Currently $($VisibilityTimeout.gettype())"
            }
        }
    }
    
    process {
        if($Peek)
        {
            return @($queue.PeekMessages($count))
        }
        else {
            if([string]::IsNullOrEmpty($VisibilityTimeout))
            {
                $Queue.GetMessages($count,$null)
            }
            else {
                $Queue.GetMessages($count,$VisibilityTimeout)
            }
        }
    }
    
    end {
        
    }
}