
import Middleware 	from './abstract'
import bugsnag 		from 'bugsnag'

export default class ErrorLogger extends Middleware

	registered: false

	constructor: (@apiKey) ->
		super()

	handle: (app, next) ->
		if not app.config.bugsnag.apiKey and not @apiKey
			throw new Error 'Bugsnag API Key not defined'

		if not @registered
			bugsnag.register @apiKey or app.config.bugsnag.apiKey, {
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


	notifyBugsnag: (error, context, input) ->
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