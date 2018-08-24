
export default class JWT

	handle: (app, next) ->
		try
			token = app.jwtDecoder app.input.token
		catch error
			throw new Error 'Authorisation Error'

		ctx.token = token

		await next()
