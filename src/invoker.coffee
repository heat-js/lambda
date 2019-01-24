
export default class Invoker

	constructor: (@lambda) ->

	invoke: (service, name, payload) ->

		result = await @lambda.invoke {
			FunctionName: 	"#{service}__#{name}"
			Payload: 		JSON.stringify payload
		}
		.promise()

		response = JSON.parse result.Payload

		if typeof response is 'object' and response isnt null and response.errorMessage

			console.error(
				'service:', service
				'name:', 	name
				'error:', 	response.errorMessage
			)

			error = new Error response.errorMessage
			error.name 		= response.errorType
			error.response 	= response
			throw error

		return response
