
import ViewableError from '../error/viewable-error'

export default class ELB

	isViewableError: (error) ->
		return (
			error instanceof ViewableError or
			(
				typeof error.message is 'string' and
				0 is error.message.indexOf '[viewable]'
			)
		)

	viewableErrorResponse: (error) ->
		search = '[viewable] '
		if typeof error.message is 'string' and 0 is error.message.indexOf search
			return { message: error.message.slice search.length }

		return { message: error.message }

	handle: (app, next) ->

		app.request = Object.freeze Object.assign {}, app.input
		app.statusCode = 200
		app.headers = {
			'content-type':					'application/json'
			'access-control-allow-origin':	'*'
			'access-control-allow-headers': 'content-type, content-length'
			'access-control-allow-methods': 'POST, GET, OPTIONS'
		}

		app.value 'formatErrorResponse', (error) =>
			if @isViewableError error
				return {
					statusCode:	error.code or 400
					headers:	app.headers
					body:		JSON.stringify @viewableErrorResponse error
				}

			return {
				statusCode: 500
				headers: app.headers
				body: JSON.stringify {
					message: 'Internal server error'
				}
			}

		if app.request.body
			try
				app.input = JSON.parse app.request.body

			catch error
				return app.output = app.formatErrorResponse new ViewableError 'Invalid request body'

		app.input = {
			...( app.request.queryStringParameters or {} )
			...( app.input or {} )
		}

		search = '[viewable] '

		try
			await next()

		catch error
			if not @isViewableError error
				console.error error
				await app.log error

			return app.output = app.formatErrorResponse error

			# if @isViewableError error
			# 	return app.output = {
			# 		statusCode:	error.code or 400
			# 		headers:	app.headers
			# 		body:		JSON.stringify @viewableErrorResponse error
			# 	}
			# else
			# 	console.error error
			# 	await app.log error

			# 	return app.output = {
			# 		statusCode: 500
			# 		headers: app.headers
			# 		body: JSON.stringify if error.response then error.response() else {
			# 			message: 'Internal server error'
			# 		}
			# 	}

		body = if app.has 'output' then app.output else {}

		return app.output = {
			statusCode:	app.statusCode
			headers:	app.headers
			body:		JSON.stringify body
		}
