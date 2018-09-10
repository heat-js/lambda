
import Middleware 	from './abstract'
import jwtDecode	from 'jwt-decode'

export default class JWT extends Middleware

	handle: (app, next) ->
		try
			app.token = jwtDecode app.input.token
		catch error
			throw new Error 'Authorisation Error'

		await next()
