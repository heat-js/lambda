
export default class Invoker

	constructor: (@lambda, @mocks = {}) ->

	invoke: (service, name, payload) ->

		if dummy = @mocks[service] and @mocks[service][name]
			if typeof dummy is 'function'
				return dummy payload

			return dummy

		result = await @lambda.invoke {
			FunctionName: "#{service}__#{name}"
			Payload: JSON.stringify payload
		}
		.promise()

		response = JSON.parse result.Payload

		if typeof response is 'object' and response isnt null and response.errorMessage
			error = new Error response.errorMessage
			error.name 		= response.errorType
			error.response 	= response
			throw error

		return response
