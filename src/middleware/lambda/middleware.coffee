
import Invoker 	from './invoker'
import AWS 		from 'aws-sdk'

export default class Lambda

	handle: (app, next) ->

		app.lambda = ->

			return new AWS.Lambda {
				apiVersion: '2015-03-31'
				region: app.config.aws.region
			}

		app.invoker = ->

			lambdaMocks = if app.has 'lambdaMocks'
				app.lambdaMocks

			return new Invoker app.lambda, lambdaMocks

		app.invoke = ->

			return app.invoker.invoke.bind app.invoker


		await next()
