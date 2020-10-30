
import ViewableError from '../error/viewable-error'

export default class Worker

	handle: (app, next) ->

		input = app.input

		# ----------------------------------------------------
		# Single work processed

		if not (typeof input is 'object' and input isnt null)
			app.value 'records', [{ payload: input }]
			await next()
			return

		if Array.isArray input
			app.value 'records', input.map (payload) ->
				return { payload }

			await next()
			return

		records = input.Records

		if not Array.isArray records
			app.value 'records', [{ payload: input }]
			await next()
			return

		# ----------------------------------------------------
		# Batch of work processed

		app.value 'records', records.map @parseRecord

		try
			await next()
		catch error
			if error instanceof ViewableError
				if app.has 'log'
					app.log error

			throw error

	parseRecord: (record) =>
		type 		= @getRecordType record
		id 			= undefined
		payload 	= undefined
		timestamp 	= undefined
		origin		= undefined
		attributes 	= {}

		# SNS
		if type is 'sns'
			id			= record.Sns.MessageId
			payload 	= JSON.parse record.Sns.Message
			timestamp 	= Date.parse record.Sns.Timestamp
			origin		= record.Sns.TopicArn.split(':')[5]

			msgAttr = record.Sns.MessageAttributes
			for key, attribute of msgAttr
				attributes[key] = attribute.Value

		# SQS
		if type is 'sqs'
			id			= record.messageId
			payload 	= JSON.parse record.body
			timestamp 	= record.attributes.SentTimestamp

			msgAttr = record.messageAttributes
			for key, attribute of msgAttr
				switch attribute.dataType
					when 'String'
						attributes[key] = attribute.stringValue

			if attributes.queue
				origin = attributes.queue

		# Async Lambda
		if type is 'lambda'
			id			= record.requestContext.requestId
			payload 	= record.requestPayload
			timestamp 	= Date.parse record.timestamp
			origin		= record.requestContext.functionArn.split(':')[6]

		return {
			type
			id
			payload
			attributes
			timestamp
			origin
			rawData: record
		}

	getRecordType: (record) ->
		if record.Sns
			return 'sns'

		if record.requestContext and record.requestPayload
			return 'lambda'

		if record.body
			return 'sqs'

		throw new Error 'Unrecognized record source: ' + JSON.stringify record
