Get-ChildItem $PSScriptRoot -Recurse -Filter "*.ps1"|Where-Object{$($_.Directory.Name) -in "Public",'private'}|ForEach-Object{
    . $_.FullName
}

$Temp = (join-path $env:temp 'UnicodeList')
new-item -ItemType Directory -Path $Temp -Force|Out-Null

$script:locations = @{
    1 = $PSScriptRoot
    2 = $Temp
}

$script:UnicodeList = @()

