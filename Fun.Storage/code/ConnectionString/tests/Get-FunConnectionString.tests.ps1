InModuleScope "fun.storage"{
    Describe "Get-FunConnectionString"{
        it "can get a string from env defined in `$env:fun_cs"{
            $env:fun_cs = "pest"
            $env:pest = "pester"
    
            Get-FunConnectionString|should -be $env:pest
        }
    }
}