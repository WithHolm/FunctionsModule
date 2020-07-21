param(
    [System.IO.FileInfo]$module = (Get-ChildItem $psscriptroot -File -filter "*.psm1"|select -first 1) 
)
if(!$module)
{
    throw "Could not find any module in path $psscriptroot"
}
# write-host "$module"
Describe "$($module.BaseName)" {
    # $ModuleName = "Fun.Storage"
    ipmo $module.fullname -Force
    $testcases = $((get-module $module.BaseName).exportedcommands.Keys|?{
        gci $module.Directory.FullName -Recurse -Filter "$_*" -Exclude "*pesterhelp*"
    }|Sort-Object|%{@{name=$_}})
    It "<name> should have a pester test" -TestCases $testcases {
        param(
            $name
        )
        gci $PSScriptRoot -Filter "$name.tests.ps1" -Recurse|should -HaveCount 1
    }
}