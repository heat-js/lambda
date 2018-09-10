
import Middleware 		from './abstract'
import AWS 				from 'aws-sdk'
import { EnvParser } 	from '../env-parser'

export default class Config extends Middleware

	config:		null
	promise:	null

	constructor: (@configBuilder) ->
		super()

	handle: (app, next) ->
		if @config
			app.config = @config
			await next()
			return

		if @promise
			await @promise
			app.config = @config
			await next()
			return

		# start resolving ssm values from the env fields
		@promise = @resolveSsmValues process.env

		# merge resolved ssm values with old env values
		data = Object.assign {}, process.env, await @promise

		# build config
		helper 		= new EnvParser data
		@config 	= @configBuilder helper
		app.config 	= @config

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

		ssm = new AWS.SSM {
			apiVersion: '2014-11-06'
		}

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
