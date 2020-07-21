InModuleScope "fun.storage"{
    Describe "New-FunStorageQueue" -Tag 'cmdlet','queue'{
        $client = New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString
    
        it "Can create a new storage queue if defined"{
            {New-FunStorageQueue -Client $client -Name "pester1"}|should -Not -Throw
            $queue = Get-FunStorageQueue -Client $client -Name "pester1"
            $queue|should -not -BeNullOrEmpty
        }
    
        it "Name cannot be empty"{
            {New-FunStorageQueue -Client $client -Name ''}|should -Throw
        }
    
        it "Will test name"{
            mock -CommandName Test-FunStorageQueueName -MockWith {return @()}
            $k = New-FunStorageQueue -Client $client -Name 'kkk'
            Assert-MockCalled -CommandName Test-FunStorageQueueName
        }
    }
}