
export default class SqsWorker

	constructor: (@workerCallback) ->

	handle: (app, next) ->

		input = app.input

		# ----------------------------------------------------
		# Single queue processed

		if not (typeof input is 'object' and input isnt null)
			await @workerCallback app, input
			await next()
			return

		records = input.Records

		if not Array.isArray records
			await @workerCallback app, input
			await next()
			return

		# ----------------------------------------------------
		# Batch of qeueue processed

		promises = []

		for record in records
			payload = JSON.parse record.body
			msgAttr = record.messageAttributes

			attributes = {}
			for key, attribute of msgAttr
				switch attribute.dataType
					when 'String'
						attributes[key] = attribute.stringValue

			promises.push @workerCallback app, payload, attributes

		await Promise.all promises

		await next()
