Describe "New-FunstorageQueueMessage" -Tag 'cmdlet','queue'{

    $Client = New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString
    $Queue = New-FunStorageQueue -Client $Client -Name "pester"

    BeforeEach{
        $Queue.Clear()
    }

    it "Can deliver a string message"{
        New-FunStorageQueueMessage -Data "pester" -Queue $Queue
        $msg = Get-FunStorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 1
        $msg.AsString|should -be "pester"
    }

    it "will accept BASE64 encoded message"{
        $bytes = [System.Text.Encoding]::Unicode.GetBytes("pester")
        $string = [Convert]::ToBase64String($bytes)
        New-FunStorageQueueMessage -Data $string -Isbase64Encoded -Queue $Queue
        $msg = Get-FunStorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 1
        $msg.AsString|should -be "pester"
    }

    it "InitialVisibilityDelay is honored"{
        New-FunStorageQueueMessage -Data "pester" -Queue $Queue -InitialVisibilityDelay "0:0:1"
        $msg = Get-FunStorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 0
        Start-Sleep -Seconds 1
        $msg = Get-FunStorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 1
        $msg.AsString|should -be "pester"
    }

    it "TimeToLove is honored"{
        New-FunStorageQueueMessage -Data "pester" -Queue $Queue -TimeToLive "0:0:1"
        $msg = Get-FunStorageQueueMessage -Queue $Queue -Peek
        $msg|should -HaveCount 1
        $msg.AsString|should -be "pester"
        $msg.ExpirationTime|should -BeGreaterOrEqual ([System.DateTimeOffset]::UtcNow.AddSeconds(1).tostring()) -Because "TTL should be 1 second"
        Start-Sleep -Seconds 1
        $msg = Get-FunStorageQueueMessage -Queue $Queue
        $msg|should -HaveCount 0 -Because "should be gone after 1 second"
    }
}