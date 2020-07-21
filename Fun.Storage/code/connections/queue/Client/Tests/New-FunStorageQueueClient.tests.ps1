describe "New-FunStorageQueueClient" -Tag 'cmdlet','queue'{
    it "Creates a new client"{
        New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString|should -BeOfType [Microsoft.Azure.Storage.Queue.CloudQueueClient]
    }
}