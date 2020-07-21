

task default -depends Test

task test{
    Invoke-Pester -Script $psake.build_script_dir
}

task buildFiles{
    gci 
}