
import Middleware from './abstract'

export default class JWT extends Middleware

	handle: (app, next) ->
		try
			token = app.jwtDecoder app.input.token
		catch error
			throw new Error 'Authorisation Error'

		ctx.token = token

		await next()
