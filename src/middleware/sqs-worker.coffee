
export default class SqsWorker

	constructor: ->

	handle: (app, next) ->

		input = app.input

		# ----------------------------------------------------
		# Single queue processed

		if not (typeof input is 'object' and input isnt null)
			app.value 'records', [input]
			await next()
			return

		records = input.Records

		if not Array.isArray records
			app.value 'records', [input]
			await next()
			return

		# ----------------------------------------------------
		# Batch of qeueue processed

		payloads = []

		for record in records
			payload = JSON.parse record.body
			msgAttr = record.messageAttributes

			attributes = {}
			for key, attribute of msgAttr
				switch attribute.dataType
					when 'String'
						attributes[key] = attribute.stringValue

			payloads.push {
				payload
				attributes
			}

		app.value 'records', payloads

		await next()
