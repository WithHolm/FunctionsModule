
# Get-FunStorageQueueMessage command help
@{
	command = 'Get-FunStorageQueueMessage'
	synopsis = ''
	description = ''
	sets = @{
		Get = ''
		Peek = ''
	}
	parameters = @{
		count = ''
		Peek = ''
		Queue = ''
		VisibilityTimeout = ''
	}
	inputs = @(
		@{
			type = ''
			description = ''
		}
	)
	outputs = @(
		@{
			type = 'Microsoft.Azure.Storage.Queue.CloudQueueMessage'
			description = ''
		}
	)
	notes = ''
	examples = @(
		@{
			#title = ''
			#introduction = ''
			code = {
			}
			remarks = ''
			test = { . $args[0] }
		}
	)
	links = @(
		@{ text = ''; URI = '' }
	)
}
