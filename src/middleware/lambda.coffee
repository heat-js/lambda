

import Middleware 	from './abstract'
import Invoker 		from '../invoker'
import AWS			from 'aws-sdk'

export default class Lambda extends Middleware

	region: (app) ->
		return (
			app.has('config') and
			app.config.aws and
			app.config.aws.region
		) or (
			process.env.AWS_REGION
		) or (
			'eu-west-1'
		)

	handle: (app, next) ->

		app.invoker = =>
			lambda = new AWS.Lambda {
				apiVersion: '2015-03-31'
				region: 	@region app
			}

			return new Invoker lambda

		app.invoke = ->
			return app.invoker.invoke.bind app.invoker

		await next()
