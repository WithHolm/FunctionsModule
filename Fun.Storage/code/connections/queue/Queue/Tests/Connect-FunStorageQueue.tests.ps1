Describe "Connect-FunStorageQueue" -Tag 'cmdlet','queue' {
    $client = New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString
    $queue = New-FunStorageQueue -Client $client -Name "pester"
    it "can connect to already existing storage queue"{
        {Connect-FunStorageQueue -Connectionstring $env:PesterStorageConnectionString -Name $queue.Name}|should -Not -Throw
    }

    it "can create new storage queue"{
        $str = $(Get-Randomstring)
        {Connect-FunStorageQueue -Connectionstring $env:PesterStorageConnectionString -Name $str -CreateIfNotExist}|should -Not -Throw
        Get-FunStorageQueue -Client $client -Name $str|should -HaveCount 1
    }

    it "can connect without storageconnectionstring if reference env is set"{
        $env:fun_cs = 'PesterStorageConnectionString'
        
    }
}