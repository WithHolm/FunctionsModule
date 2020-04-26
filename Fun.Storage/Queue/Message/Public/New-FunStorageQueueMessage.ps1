using namespace Microsoft.Azure.Storage
function New-FunStorageQueueMessage {
    [CmdletBinding()]
    param (
        [object[]]$Data,
        [parameter(HelpMessage="should data be Base64 encoded?")]
        [Switch]$Encode,
        [Microsoft.Azure.Storage.Queue.CloudQueue]$Queue,
        [parameter(
            HelpMessage = "
            String or Timespan.
            String follows following protocoll:
            '1' = 1 day
            '1:0' = 1 hour
            '0:1' = 1 minute
            '0:0:1' = 1 second
            "
        )]
        [timespan]$MessageLongevity
    )
    
    begin {
        
    }
    
    process {
        $Message = [Queue.CloudQueueMessage]::new($($data -join ''),$Encode.IsPresent)
        # $Message.ExpirationTime
        if($MessageLongevity)
        {
            [void]$Queue.AddMessageAsync($Message,$MessageLongevity,([timespan]::Zero),$null,$null)
        }
        else {
            [void]$Queue.AddMessageAsync($Message)
        }
    }
    
    end {
    }
}
