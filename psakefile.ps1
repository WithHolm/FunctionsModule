Properties{
    $InformationPreference = "contiune"
    
}
task default -depends enablepester,storage,disablePester #import,pester

task Storage -depends import_storage,pester_storage

task enablepester {
    $global:pesteractive = $true
}
task disablePester {
    $global:pesteractive = $false
}

task import_storage{
    Import-Module (join-path $psake.build_script_dir "fun.storage") -Force
    Get-ChildItem (join-path $psake.build_script_dir "fun.storage/pester") -Filter "*.ps1"|%{
        . $_.FullName
    }
}

task Pester_Storage -action {
    $env:PesterStorageConnectionString = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;"
    invoke-pester -Script $(Get-ChildItem (join-path $psake.build_script_dir "Fun.Storage") -Recurse -Filter "*.tests.ps1" -File).fullname -Show Summary, Failed, Passed, Describe
}