using namespace Microsoft.Azure.Storage

function New-FunstorageQueueClient {
    [CmdletBinding()]
    [outputtype([Microsoft.Azure.Storage.Queue.CloudQueueClient])]
    param (
                [parameter(HelpMessage="
            Storage account connection string. 
            if you have a environment variable that stores this key, you can define the variable name by setting 'fun_cs' in environment or app config.
        ")]
        [String]$Connectionstring = (Get-FunConnectionString)
    )
    
    begin {
        if([string]::IsNullOrEmpty($Connectionstring))
        {
            Write-verbose "`$env:fun_cs set:$([string]::IsNullOrEmpty($env:fun_cs)), Value:'$env:fun_cs'"
            throw "Missing connectionstring"
        }
    }
    
    process {
        $CS = [Microsoft.Azure.Storage.cloudstorageaccount]::Parse($Connectionstring)
        $q = $([Queue.CloudQueueClient]::new($cs.QueueStorageUri,$CS.Credentials))
        if([string]::IsNullOrEmpty($q))
        {
            throw "failed to create queue client"
        }
        else {
            return $q
        }
    }
    
    end {
    }
}