
import Middleware 	 from './abstract'
import bugsnag 		 from '@bugsnag/js'
import ViewableError from '../error/viewable-error'

export default class ErrorLogger extends Middleware

	constructor: (@apiKey) ->
		super()

	getApiKey: (app) ->
		return (
			@apiKey or
			(
				app.has('config') and
				app.config.bugsnag and
				app.config.bugsnag.apiKey
			) or
			process.env.BUGSNAG_API_KEY
		)

	handle: (app, next) ->

		apiKey = @getApiKey app

		if not apiKey
			throw new Error 'Bugsnag API key not found'

		if typeof apiKey isnt 'string'
			throw new Error 'Bugsnag API key should be a string'

		if not @bugsnag
			@bugsnag = bugsnag {
				apiKey
				projectRoot: process.cwd()
				packageJSON: process.cwd() + '/package.json'
				logger: null
			}

		app.value 'bugsnag', @bugsnag
		app.value 'notify', (error, metaData = {}) =>
			return @notify(
				error
				app.context
				app.input
				metaData
			)

		try
			await next()

		catch error
			if not ( error instanceof ViewableError )
				await app.notify error

			throw error

	notify: (error, context = {}, input = {}, metaData = {}) ->

		params = {
			metaData: Object.assign {}, metaData, {
				input
				lambda:
					requestId: 			context.awsRequestId
					functionName: 		context.functionName
					functionVersion:	context.functionVersion
					memoryLimitInMB:	context.memoryLimitInMB
			}
		}

		return new Promise (resolve, reject) =>
			@bugsnag.notify error, params, (err) ->
				if err
					reject err
				else
					resolve()
