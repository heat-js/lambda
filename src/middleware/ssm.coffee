
import Middleware from './abstract'

done 		= false
promise 	= null

export default class SSM extends Middleware

	handle: (app, next) ->
		if done
			await next()
			return

		if promise
			await promise
			await next()
			return

		promise = @fetch()
		await promise
		done = true

		await next()

	fetch: ->
		paths = @parseSSM()
		names = paths.map (i) -> i.path

		if !names.length
			return

		params = {
			Names: names
			WithDecryption: true
		}

		try
			result = await @ssm.getParameters(params).promise()
		catch error
			throw error

		if result.InvalidParameters and result.InvalidParameters.length
			throw new Error "SSM parameter(s) not found - ['ssm:#{
				result.InvalidParameters.join "', 'ssm:"
			}']"

		values = @parseValues result.Parameters

		for item in paths
			process.env[item.key] = values[item.path]


	parseValues: (params) ->
		values = {}

		for item in params
			if item.Type is 'StringList'
				values[item.Name] = item.Value.split ','
			else
				values[item.Name] = item.Value

		return values


	parseSSM: (object) ->
		list = []

		for key, value of process.env
			if value.substr(0, 4) is 'ssm:'
				list.push {
					path: value.substr 4
					key
				}

		return list
