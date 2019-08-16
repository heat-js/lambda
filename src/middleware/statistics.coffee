
import Middleware 	from './abstract'
import AWS			from 'aws-sdk'

export default class StatisticsMiddleware extends Middleware

	handle: (app, next) ->

		app.statistics = ->
			return new Statistics app.sqs

		await next()


export default class Statistics

	constructor: (@sqs) ->

	put: ({ name, value, unit, dimensions }) ->
		return @sqs.send(
			'statistics'
			'metric'
			{
				name
				value
				unit
				dimensions
			}
		)
