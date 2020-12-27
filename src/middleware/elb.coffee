
import ViewableError from '../error/viewable-error'

export default class ELB

	handle: (app, next) ->

		app.request = Object.freeze Object.assign {}, app.input
		app.headers = {
			'content-type':					'application/json'
			'access-control-allow-origin':	'*'
			'access-control-allow-headers': 'content-type, content-length'
			'access-control-allow-methods': 'POST, GET, OPTIONS'
		}

		try
			app.input = JSON.parse app.request.body or '{}'

		catch error
			return app.output = {
				statusCode: 400
				headers: app.headers
				body: JSON.stringify {
					message: error.message.slice search.length
				}
			}

		app.input = {
			...app.request.queryStringParameters
			...app.input
		}

		search = '[viewable] '

		try
			await next()

		catch error
			if error instanceof ViewableError or 0 is error.message.indexOf search
				return app.output = {
					statusCode: 400
					headers: app.headers
					body: JSON.stringify {
						message: error.message.slice search.length
					}
				}
			else
				console.error error
				await app.log error

				return app.output = {
					statusCode: 500
					headers: app.headers
					body: JSON.stringify {
						message: 'Internal server error'
					}
				}

		body = if app.has 'output' then app.output else {}

		return app.output = {
			statusCode: 200
			headers: app.headers
			body: JSON.stringify body
		}
