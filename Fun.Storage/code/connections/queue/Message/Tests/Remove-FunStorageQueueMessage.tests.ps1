Describe "Remove-FunStorageQueueMessage" -Tag 'cmdlet','queue'{
    $Client = New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString
    $Queue = New-FunStorageQueue -Client $Client -Name "pester"
    BeforeEach{
        $Queue.Clear()
    }

    it "removes a specific message" {
        New-FunStorageQueueMessage -Data "pester" -Queue $Queue
        $msg = Get-FunStorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        $msg|should -HaveCount 1
        Remove-FunStorageQueueMessage -Queue $Queue -message $msg
        Start-Sleep -Milliseconds 100
        $msg = Get-FunStorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        $msg|should -HaveCount 0
    }
    it "accepts pipeline" {
        New-FunStorageQueueMessage -Data "pester" -Queue $Queue
        $msg = Get-FunStorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        $msg|should -HaveCount 1
        $msg|Remove-FunStorageQueueMessage -Queue $Queue
        Start-Sleep -Milliseconds 100
        $msg = Get-FunStorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        $msg|should -HaveCount 0
    }
    it "throws on messages that are peeked" {
        New-FunStorageQueueMessage -Data "pester" -Queue $Queue
        $msg = Get-FunStorageQueueMessage -Queue $Queue -Peek
        $msg|should -HaveCount 1
        {$msg|Remove-FunStorageQueueMessage -Queue $Queue}|should -Throw
        # Start-Sleep -Milliseconds 100
        # $msg = Get-FunStorageQueueMessage -Queue $Queue -VisibilityTimeout "0:0:0.1"
        # $msg|should -HaveCount 0
    }
}