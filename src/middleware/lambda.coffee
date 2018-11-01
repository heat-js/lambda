

import Middleware 	from './abstract'
import Invoker 		from '../invoker'
import AWS			from 'aws-sdk'

export default class Lambda extends Middleware

	handle: (app, next) ->

		app.invoker = ->
			lambdaClient = new AWS.Lambda {
				apiVersion: '2015-03-31'
				region: app.config.aws.region
			}

			return new Invoker lambdaClient

		await next()
