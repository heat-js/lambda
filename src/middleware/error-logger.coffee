
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
			return await next()

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
				await @notify(
					error
					app.context
					app.input
				)

			throw error

	notify: (error, context = {}, input = {}, metaData = {}) ->
		return new Promise (resolve, reject) =>
			@bugsnag.notify error, {
				app:
					name: context.functionName
				input
				metaData: Object.assign {}, metaData, {
					requestId: 			context.awsRequestId
					functionName: 		context.functionName
					functionVersion:	context.functionVersion
					memoryLimitInMB:	context.memoryLimitInMB
				}

			}, (error) ->
				if error
					reject error
				else
					resolve()
