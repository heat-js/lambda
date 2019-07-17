
import Middleware 		from './abstract'
import AWS 				from 'aws-sdk'

export default class SSM extends Middleware

	constructor: (@saveInMemory = true, @clientOptions = {}) ->
		super()

	handle: (app, next) ->
		if @saveInMemory and @promise
			await @promise
			return next()

		@promise = @resolveSsmValues process.env
		env = await @promise

		Object.assign process.env, env
		await next()

	resolveSsmValues: (input) ->
		paths = @getSsmPaths input
		names = paths.map (i) -> i.path

		if !names.length
			return

		params = {
			Names: names
			WithDecryption: true
		}

		options = Object.assign {
			apiVersion: '2014-11-06'
		}, @clientOptions

		ssm = new AWS.SSM options

		result = await ssm.getParameters(params).promise()

		if result.InvalidParameters and result.InvalidParameters.length
			throw new Error "SSM parameter(s) not found - ['ssm:#{
				result.InvalidParameters.join "', 'ssm:"
			}']"

		values = @parseValues result.Parameters

		output = {}
		for item in paths
			output[item.key] = values[item.path]

		return output

	parseValues: (params) ->
		values = {}

		for item in params
			if item.Type is 'StringList'
				values[item.Name] = item.Value.split ','
			else
				values[item.Name] = item.Value

		return values

	getSsmPaths: (object) ->
		list = []

		for key, value of object
			if value.substr(0, 4) is 'ssm:'
				list.push {
					path: value.substr 4
					key
				}

		return list
