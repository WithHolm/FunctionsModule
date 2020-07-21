using namespace System.Net
using namespace Microsoft.Azure
using namespace Microsoft.Azure.Storage
# using namespace Microsoft.Extensions.Configuration
# using namespace Microsoft.Extensions.Configuration.AzureAppConfiguration
# Input bindings are passed in via param block.
param(
    [Microsoft.Azure.Functions.PowerShellWorker.HttpRequestContext]$Request, 
    [hashtable]$TriggerMetadata
)

# connect via connection string directly
$Queue = Connect-FunStorageQueue -Connectionstring $env:AzureWebJobsStorage -Name 'somequeue' -CreateIfNotExist

# Connect using reference to env variable set in 'env:fun_cs'
# env:fun_cs = 'AzureWebJobsStorage'
# env:AzureWebJobsStorage = connectionstring
$Queue = Connect-FunStorageQueue -Name 'somequeue' -CreateIfNotExist

#region messages
    #add message to queue
    New-FunStorageQueueMessage -Data "this is a message" -Queue $Queue

    #add a message that only is present in queue 1 minute
    New-FunStorageQueueMessage -Data "this is a message" -Queue $Queue -MessageLongevity "0:1"
    #alternative with proper timespan
    New-FunStorageQueueMessage -Data "this is a message" -Queue $Queue -MessageLongevity ([timespan]::FromMinutes(1))
#endregion


#peek messages. read them without actually marking them as 'read'. a pop receipt will not be added
$k = Get-FunStorageQueueMessage -Queue $Queue -Peek

#read messages
$l = Get-FunStorageQueueMessage -Queue $Queue