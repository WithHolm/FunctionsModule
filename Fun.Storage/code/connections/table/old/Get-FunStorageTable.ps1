using namespace Microsoft.Azure.Storage
function Get-FunStorageTable {
    [CmdletBinding()]
    [OutputType([Microsoft.Azure.Cosmos.Table.CloudTable])]
    param (
        [parameter(Mandatory)]
        [String]$Connectionstring,
        [parameter(Mandatory)]
        [String]$Name,
        [switch]$CreateIfNotExist
    )
    
    begin {
    }
    
    process {
        $cs = [Microsoft.Azure.Cosmos.Table.CloudStorageAccount]::Parse($Connectionstring)
        [Microsoft.Azure.Cosmos.Table.CloudTableClient]$TableClient = [Microsoft.Azure.Cosmos.Table.CloudTableClient]::new($cs.TableEndpoint,$cs.Credentials)
        [Microsoft.Azure.Cosmos.Table.CloudTable]$Table = [Microsoft.Azure.Cosmos.Table.CloudTable]$TableClient.GetTableReference($Name)
        if($CreateIfNotExist)
        {
            [void]$table.CreateIfNotExists()
        }
        return $Table
    }
    
    end {
        
    }
}