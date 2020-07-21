function New-HelpXml {
    [CmdletBinding()]
    param (
        [string]$Command
    )
    
    begin {
        
    }
    
    process {
        [ordered]@{
            xml = 'version="1.0" encoding="utf-8"'
            helpItems = @{
                schema = maml
            }
        }
    }
    
    end {
        
    }
}