function New-FunStorageQueue {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory,
            HelpMessage = "{QueueClient}"
        )]
        [ValidateNotNullOrEmpty()][Microsoft.Azure.Storage.Queue.CloudQueueClient]$Client,
        
        [parameter(
            Mandatory,
            HelpMessage= "Name of queue. look at https://docs.microsoft.com/en-us/rest/api/storageservices/naming-queues-and-metadata for naming limits"    
        )]
        [ValidateNotNullOrEmpty()]
        [String]$Name
    )
    
    begin {
        $ValidateName = Test-QueueName -Name $Name
        if($ValidateName.count -gt 0)
        {
            throw "Error validating queue-name '$name': $($ValidateName -join ", ")"
        }

    }
    process {
        Write-Verbose "Creating Queue '$Name'"
        $Queue = $Client.GetQueueReference($Name)
        [void] $Queue.CreateIfNotExists()
        return $Queue
    }
    end {}
}