

export default class Invoker

	constructor: (@lambda, @mocks = {}) ->

	invoke: (service, name, payload) ->

		if dummy = @mocks[name] and @mocks[name][payload]
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
