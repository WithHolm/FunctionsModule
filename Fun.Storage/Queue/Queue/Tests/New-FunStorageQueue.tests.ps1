Describe "New-FunStorageQueue"{
    $client = New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString

    it "can create a new storage queue"{
        {New-FunStorageQueue -Client $client -Name "pester1"}|should -Not -Throw
    }
}