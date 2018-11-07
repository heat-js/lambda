

import Middleware 	from './abstract'
import Invoker 		from '../invoker'
import AWS			from 'aws-sdk'

export default class Lambda extends Middleware

	region: ->
		return (
			app.has('config') and
			app.config.aws and
			app.config.aws.region
		) or (
			process.env.AWS_REGION
		)

	handle: (app, next) ->

		app.invoker = ->
			lambda = new AWS.Lambda {
				apiVersion: '2015-03-31'
				region: 	@region()
			}

			return new Invoker lambda

		app.invoke = ->
			return app.invoker.invoke.bind app.invoker

		await next()
