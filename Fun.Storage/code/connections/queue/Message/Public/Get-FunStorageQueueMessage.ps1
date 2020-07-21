
function Get-FunStorageQueueMessage {
    [CmdletBinding(DefaultParameterSetName="Get")]
    [outputtype([Microsoft.Azure.Storage.Queue.CloudQueueMessage])]
    param (

        [parameter(
            HelpMessage="{Queue}",
            Mandatory, 
            ValueFromPipeline
        )]
        [Microsoft.Azure.Storage.Queue.CloudQueue]$Queue,

        [parameter(
            HelpMessage="How many messages to get"
        )]
        [ValidateRange(1,32)]
        [int]$count = 32,

        [parameter(
            ParameterSetName="Peek",
            HelpMessage="
                If set, it will only look at message, but not hide message for others to look at. 
                you cannot do any actions (set, remove) on a peeked message
            "
        )]
        [switch]$Peek,

        [parameter(
            ParameterSetName="Get",
            HelpMessage="
            How long will you lease the message for? Will use default 90 sec is not defined.
            {Timespan.types}
            {Timespan.protocoll}
            "
        )]
        [timespan]$VisibilityTimeout
    )
    
    begin {
        if($VisibilityTimeout -eq [timespan]0)
        {
            Write-warning "Cannot have a timespan of 0. setting this to 0.0001 Ms"
            $VisibilityTimeout = [timespan]1
        }
        # if([string]::IsNullOrEmpty($VisibilityTimeout))
        # {
        #     # if($VisibilityTimeout -is [timespan])
        #     # {
        #     #     #do nothing
        #     # }
        #     # elseif($VisibilityTimeout -is [string])
        #     # {
        #     #     [timespan]::Parse($VisibilityTimeout)
        #     # }
        #     # else {
        #     #     Throw "Input type is not string or timespan: Currently $($VisibilityTimeout.gettype())"
        #     # }
        # }
    }
    
    process {
        Write-Verbose "Count: $count"
        Write-verbose "visibilitytimeout: $VisibilityTimeout"
        if($Peek)
        {
            return @($queue.PeekMessages($count))
        }
        else {
            if([string]::IsNullOrEmpty($VisibilityTimeout))
            {
                #default visibility timeout is 
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