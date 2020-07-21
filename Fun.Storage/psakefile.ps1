Properties {
    $InformationPreference = "contiune"
}
Properties{
    $TempFolder = Join-Path $env:TEMP (split-path $psake.build_script_dir -Leaf)
    $StorageEmulatorPath = "C:\Program Files (x86)\Microsoft SDKs\Azure\Storage Emulator\AzureStorageEmulator.exe"
}
task default -depends test,build,publish

task build -depends build_clean_pester,build_create_docs

task test -depends pester_CheckStorageEmulator,pester_enable, pester_import, pester, pester_disable

task pester_enable { 
    $global:pesteractive = $true 
}

task pester_disable { 
    $global:pesteractive = $false 
}

task pester_import { 
    Write-Host "importing $($psake.build_script_dir)"
    Import-Module $psake.build_script_dir -Force
}

task pester_CheckStorageEmulator{
    if(test-path $StorageEmulatorPath)
    {
        #get status, convert output to a object
        $statusSb = {exec -cmd {& $StorageEmulatorPath status}|Where-Object{$_ -like "*:*"}|ConvertFrom-StringData -Delimiter ":"}
        $status = $statusSb.Invoke()
        #if its not started
        if(![bool]::Parse($status.isrunning))
        {
            Write-host "starting storage emulator"
            exec -cmd {& $StorageEmulatorPath start}

            start-sleep -Seconds 1

            Write-host "Confirming that its started"
            $status = $statusSb.Invoke()
            if(![bool]::Parse($status.isrunning))
            {
                throw "Cannot start storage emulator"
            }
        }
    }
    else {
        Throw "Could not find Azure storage Emulator at given location: '$StorageEmulatorPath'. please install: https://docs.microsoft.com/en-us/azure/storage/common/storage-use-emulator"
    }
}

task Pester -action {
    # Standard key to storage emulator
    $keyhash = [ordered]@{
        DefaultEndpointsProtocol = "http"
        AccountName              = 'devstoreaccount1'
        AccountKey               = 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=='
        BlobEndpoint             = "http://127.0.0.1:10000/devstoreaccount1"
        TableEndpoint            = "http://127.0.0.1:10002/devstoreaccount1"
        QueueEndpoint            = "http://127.0.0.1:10001/devstoreaccount1"
    }
    $env:PesterStorageConnectionString = ($keyhash.GetEnumerator() | % { 
        "$($_.Key)=$($_.Value);" }) -join ""
    $TestFiles = Get-ChildItem $psake.build_script_dir -Recurse -Filter "*.tests.ps1" -File
    $show = "Summary", "Failed", "Passed", "Describe"
    # $show = "Failed"
    # $Tags = @('module',"cmdlet")
    $total = 0
    foreach($tag in 'module',"cmdlet")
    {
        write-host "testing '$tag' showing $($show -join ", ")"
        
        $pester = invoke-pester -Script $TestFiles.fullname -Show $show -PassThru -Tag $tag
        if($pester.FailedCount -gt 0)
        {
            throw "$tag tests: $($pester.FailedCount) pester tests failed"
        }
        else {
            $total += $pester.TotalCount
        }
    }
    Write-Host "$total tests completed. no erors found!"

}

task build_clean_tempfolder{
    if(!(Test-Path $TempFolder))
    {
        Write-Host "Creating '$TempFolder'"
        New-Item $TempFolder -ItemType Directory|Out-Null
    }
    else {
        Write-Host "Cleaning '$TempFolder'"
        Get-ChildItem $TempFolder -Force|remove-item -Recurse -Force
    }
}

task build_copyto_temp -depends build_clean_tempfolder {
    Write-host "copying from '$($psake.build_script_dir)' to '$TempFolder'"
    gci $($psake.build_script_dir) -Force|copy-item -Destination $TempFolder -Recurse -Force
}

task build_clean_pester -depends build_copyto_temp -action {
    Write-host "Removing pester files"
    gci $TempFolder -Filter "tests" -Directory -Recurse |Remove-Item -Recurse -Force

    write-host "removing pester helper files"
    gci $TempFolder -Filter "*.pesterhelp.ps1" -Directory -Recurse|remove-item -Recurse -Force

    write-host "removing module test file"
    gci $TempFolder -Filter "*.moduletests.ps1"|Remove-Item
}

task build_create_docs {

}

task publish{

}

# task cleanup {
#     Write-host "removing "
# }