
import handle 	from '../src/handle'
import Worker 	from '../src/middleware/worker'

lambda = handle(
	new Worker
	(app) ->
		output = app.records.map (record) ->
			return record.payload

		app.output = output
)

describe 'Test Worker Middleware', ->

	snsMessage = {
		Records: [
			{
				"EventSource": "aws:sns",
				"EventVersion": "1.0",
				"EventSubscriptionArn": "arn:aws:sns:eu-west-1:123456789:lambda:7fa92437-7910-4453-b5db-69cbc8aecf5b",
				"Sns": {
					"Type": "Notification",
					"MessageId": "f553fe9c-306b-5be2-ab89-a9ea5aea2afc",
					"Timestamp": "2019-01-02T12:45:07.000Z",
					"TopicArn": "arn:aws:sns:eu-west-1:519177113932:betting__bet",
					"Subject": null,
					"Message": "{\"userId\":123}",
					"MessageAttributes": {
						"snsTopic": {
							"Type": "String",
							"Value": "betting__bet"
						}
					}
				}
			}
		]
	}

	it 'should return same output as input', ->
		input = [ {}, {} ]
		expect await lambda input
			.toStrictEqual input

		expect await lambda snsMessage
			.toStrictEqual [{ userId: 123 }]
