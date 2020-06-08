
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

	parseRecord: (record) ->
		# SNS
		if record.Sns
			return JSON.parse record.Sns.Message

		# SQS
		if record.body
			return JSON.parse record.body

		throw new Error 'Unrecognized record source: ' + JSON.stringify record
