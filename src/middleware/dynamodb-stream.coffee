
import AWS from 'aws-sdk'

export default class DynamoDBStream

	handle: (app, next) ->

		input = app.input

		# ----------------------------------------------------
		# Single queue processed

		if not (typeof input is 'object' and input isnt null)
			app.value 'records', [ input ]
			await next()
			return

		records = input.Records

		if not Array.isArray records
			app.value 'records', [ input ]
			await next()
			return

		# ----------------------------------------------------
		# Batch of qeueue processed

		app.value 'records', records.map (record) ->
			newImage = record.dynamodb.NewImage
			newImage = newImage and AWS.DynamoDB.Converter.unmarshall newImage

			oldImage = record.dynamodb.OldImage
			oldImage = oldImage and AWS.DynamoDB.Converter.unmarshall oldImage

			return {
				newImage
				oldImage
			}

		await next()
