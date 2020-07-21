function Get-FunConnectionString {
    [CmdletBinding()]
    param ()
    
    begin {
        
    }
    
    process {
        if(![string]::IsNullOrEmpty($env:fun_cs))
        {
            "`$env:$($env:fun_cs)"|Invoke-Expression
        }
    }
    
    end {
        
    }
}