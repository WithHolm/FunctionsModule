using namespace Microsoft.Azure.Storage
Describe "Clear-FunStorageQueue" -Tag 'cmdlet','queue'{
    $client = New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString -Verbose
    $queue = New-FunStorageQueue -Name (Get-Randomstring) -Client $Client

    it "Can clear queue by pipeline" -test {
        New-FunStorageQueueMessage -Data (get-randomMessage) -Queue $queue

        $queue|Get-FunStorageQueueMessage -Peek|should -HaveCount 1
        $queue|Clear-FunStorageQueue
        $queue|Get-FunStorageQueueMessage -Peek|should -HaveCount 0
    }

    it "Can clear queue by parameters - queue" -test {
        New-FunStorageQueueMessage -Data (get-randomMessage) -Queue $queue

        $queue|Get-FunStorageQueueMessage -Peek|should -HaveCount 1
        Clear-FunStorageQueue -Queue $queue
        $queue|Get-FunStorageQueueMessage -Peek|should -HaveCount 0
    }

    it "Can clear queue by parameters - name + client" -test {
        New-FunStorageQueueMessage -Data (get-randomMessage) -Queue $queue

        $queue|Get-FunStorageQueueMessage -Peek|should -HaveCount 1
        Clear-FunStorageQueue -name $queue.Name -client $queue.ServiceClient
        $queue|Get-FunStorageQueueMessage -Peek|should -HaveCount 0
    }

    it "will fail when name is defined and client not defined"{
        {Clear-FunStorageQueue -name $queue.Name}|should -Throw
    }

    it "will fail when client is defined and no name is present"{
        {Clear-FunStorageQueue -client $queue.ServiceClient}|should -Throw
    }
}