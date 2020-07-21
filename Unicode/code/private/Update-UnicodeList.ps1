function Update-UnicodeDataSet {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {

        # $k = Invoke-WebRequest -Uri 'http://www.unicode.org/Public/UNIDATA/UnicodeData.txt'
        # $data = irm http://www.unicode.org/Public/UNIDATA/UnicodeData.txt | ConvertFrom-Csv -Delim ";" -Header Code, Name, Category
    }
    
    end {
        
    }
}