
import AWS 	from 'aws-sdk'

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


export class Invoker

	constructor: (@lambda, @mocks = {}) ->

	invoke: (service, name, payload) ->

		if dummy = @mocks[name] and @mocks[name][payload]
			if typeof dummy is 'function'
				return dummy payload

			return dummy

		result = await @lambda.invoke {
			FunctionName: "#{service}__#{name}"
			Payload: JSON.stringify payload
		}
		.promise()

		response = JSON.parse result.Payload

		if typeof response is 'object' and response.errorMessage
			error = new Error response.errorMessage
			error.name 		= response.errorType
			error.response 	= response
			throw error

		return response
