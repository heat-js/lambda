
import Middleware 	from './abstract'
import AWS			from 'aws-sdk'

export default class StatisticsMiddleware extends Middleware

	handle: (app, next) ->

		app.statistics = ->
			return new Statistics app.sqs

		await next()


export class Statistics

	constructor: (@sqs) ->

	put: (metric) ->

		if not Array.isArray metric
			metric = [ metric ]

		metric = metric.map (item) ->
			return {
				name: 		item.name
				value: 		item.value
				unit: 		item.unit
				dimensions: item.dimensions
				date:		item.date or (new Date).toISOString()
			}

		return @sqs.send(
			'statistics'
			'metric'
			metric
		)
