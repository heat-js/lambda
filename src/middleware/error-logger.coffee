
import Middleware 	from './abstract'
import bugsnag 		from '@bugsnag/js'

export default class ErrorLogger extends Middleware

	registered: false

	constructor: (@apiKey) ->
		super()

	getApiKey: (config) ->
		return @apiKey or ( config.bugsnag and config.bugsnag.apiKey )

	handle: (app, next) ->
		if not @getApiKey app.config
			return await next()

		if not @registered
			bugsnag.register @getApiKey app.config, {
				projectRoot: process.cwd()
				packageJSON: process.cwd() + '/package.json'
			}
			@registered = true

		try
			await next()
		catch error
			if not error.viewable
				await @notifyBugsnag error, app.context, app.input
			throw error


	notifyBugsnag: (error, context = {}, input = {}) ->
		return new Promise (resolve, reject) ->
			bugsnag.notify error, {
				app:
					name: context.functionName
				input
				metaData:
					functionName: context.functionName
					functionVersion: context.functionVersion
					requestId: context.awsRequestId
					memoryLimitInMB: context.memoryLimitInMB
			}, (error) ->
				if error
					reject error
				else
					resolve()
