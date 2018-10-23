
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
			bugsnag.register @apiKey or app.config.bugsnag.apiKey
			@registered = true

		try
			await next()
		catch error
			await @notifyBugsnag error, app.context
			throw error


	notifyBugsnag: (error, context) ->
		return new Promise (resolve, reject) ->
			bugsnag.notify error, {
				appVersion: context.functionVersion
				group: context.functionName
				metaData: context
				request:
					id: context.awsRequestId
			}, (error) ->
				if error
					reject error
				else
					resolve()
