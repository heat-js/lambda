
import Middleware 		from './abstract'
import AWS 				from 'aws-sdk'

export default class SSM extends Middleware

	constructor: (@saveInMemory = true) ->
		super()

	handle: (app, next) ->
		if @saveInMemory and @promise
			await @promise
			return next()

		app.ssmClient = =>
			await @setAwsCredentials app

			return new AWS.SSM {
				apiVersion: '2014-11-06'
			}

		@promise = @resolveSsmValues process.env, app.ssmClient
		env = await @promise

		Object.assign process.env, env
		await next()

	resolveSsmValues: (input, client) ->
		paths = @getSsmPaths input
		names = paths.map (i) -> i.path

		if !names.length
			return

		params = {
			Names: names
			WithDecryption: true
		}

		result = await client.getParameters(params).promise()

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
