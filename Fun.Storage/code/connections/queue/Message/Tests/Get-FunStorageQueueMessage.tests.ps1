Describe "Get-FunStorageQueueMessage" -Tag 'cmdlet','queue'{
    $Client = New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString
    $Queue = New-FunStorageQueue -Client $Client -Name "pester"

    describe "Normal"{
        BeforeEach{
            $Queue.Clear()
        }
        #Create message
        # New-FunStorageQueueMessage -Data "pester" -Queue $Queue

        it "delivers Microsoft.Azure.Storage.Queue.CloudQueueMessage"{
            $msg = [Queue.CloudQueueMessage]::new("pester",$false)
            $Queue.AddMessage($msg)

            Get-FunStorageQueueMessage -Queue $Queue -count 1|should -BeOfType [Microsoft.Azure.Storage.Queue.CloudQueueMessage] 
        }

        $testcase = @(1,5,10,15,32)|%{@{count=$_}}
        it "Loads <count> messages when instructed" -TestCases $testcase {
            param(
                [int]$count
            )
            @(0..$count)|%{
                # Write-host "created message"
                $msg = [Queue.CloudQueueMessage]::new("pester$_",$false)
                $Queue.AddMessage($msg)
                # New-FunStorageQueueMessage -Data "pester$_" -Queue $Queue
            }
            Start-Sleep -Milliseconds 100
            $Messages = Get-FunStorageQueueMessage -Queue $Queue -count $count -VisibilityTimeout 1
            $Messages|should -HaveCount $count
            $Messages|%{
                $_.AsString|should -BeLike "pester*"
            }
            # $Queue.Clear()
        }
        
        it "Throws when loading <msg> <count> messages" -TestCases @(
            @{
                msg="more than"
                count = 32
                using = 33
            }
            @{
                msg="less than"
                count = 1
                using = 0
            }
        ) -Test {
            param(
                $msg,
                $count,
                $using
            )
            @(0..$count)|%{
                $msg = [Queue.CloudQueueMessage]::new("pester$_",$false)
                $Queue.AddMessage($msg)
            }
            {Get-FunStorageQueueMessage -Queue $Queue -count $using -VisibilityTimeout 1000}|should -Throw
        }
        
        # Clear-FunStorageQueue -Queue $Queue
        it "Visibilitytimeout is honored"{
            $msg = [Queue.CloudQueueMessage]::new("pester",$false)
            $Queue.AddMessage($msg)
            # New-FunStorageQueueMessage -Data "pester" -Queue $Queue
            Start-Sleep -Milliseconds 100
            $msg = Get-FunStorageQueueMessage -Queue $Queue -count 1
            Get-FunStorageQueueMessage -Queue $Queue -count 1|should -HaveCount 0
        }
    }
    describe "Peek"{
        BeforeEach{
            $Queue.Clear()
            $msg = [Queue.CloudQueueMessage]::new("pester",$false)
            $Queue.AddMessage($msg)
            # New-FunStorageQueueMessage -Data "pester" -Queue $Queue
        }
        # $Queue.Clear()
        
        it "can peek message"{
            Get-FunStorageQueueMessage -Queue $Queue -count 1 -Peek|should -HaveCount 1
        }
        it "visibility not affected"{
            Get-FunStorageQueueMessage -Queue $Queue -count 1 -Peek|should -HaveCount 1
            Get-FunStorageQueueMessage -Queue $Queue -count 1 -Peek|should -HaveCount 1
        }
        it "delivers Microsoft.Azure.Storage.Queue.CloudQueueMessage"{
            Get-FunStorageQueueMessage -Queue $Queue -count 1 -Peek|should -BeOfType [Microsoft.Azure.Storage.Queue.CloudQueueMessage] 
        }
    }

}