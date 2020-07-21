class UnicodeItem {
    [string]$Code
    [string]$Name
    [string]$Category
    [string]$CombineClass
    [string]$BidiClass
    [string]$Deomp
    [string]$Number
    [string]$Mirrored
    [string]$OldName
    [string]$Comment
    [string]$UpperCase
    [string]$LowerCase
    [string]$_TitleCase

    UnicodeItem([string]$txtline)
    {

    }

    [string] AsRegex()
    {

        return "\u$(this.code)"
    }

    [int] AsDecimal()
    {
        $sb = [scriptblock]::Create("0x$($this.Code)")
        return $sb.Invoke()
    }
}

# class Category{

# }

# Update-TypeData -MemberType ScriptProperty -MemberName TitleCase -Value 