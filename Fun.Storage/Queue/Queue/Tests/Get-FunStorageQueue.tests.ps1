Describe "Get-FunStorageQueue"{
    $client = New-FunstorageQueueClient -Connectionstring $env:PesterStorageConnectionString
    $client.ListQueues()|%{$_.delete()}
    $queues = @("pester-one","pester-two","test-one","test-two","test-three","philip-one","philip-two","philip-three","philip-four","testing-1","hey-1","hey-2")
    $queues|ForEach-Object{
        New-FunStorageQueue -Name $_ -Client $Client
    }
    It "lists avalible queues if avalible" -Test {
        @(Get-FunStorageQueue -Client $client)|should -HaveCount $queues.Count
    }

    it "lists avalible queues with prefix <name>" -TestCases @(
        (
            #Foreach Queue
            $queues|%{
            #split by "-" and select first item
            $_.split("-")[0]}|
                #get unique.. ie pester, test, philip, 
                select -Unique|%{
                    #Create hashtable
                    @{name = $_}
                }
        )
    ) -Test {
        param(
            [string]$Name
        )
        (Get-FunStorageQueue -Client $client -Name $Name)|should -HaveCount @($queues|?{$_ -like "$name*"}).Count
    }

}