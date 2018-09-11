
import Middleware 	from './abstract'
import jwtDecode	from 'jwt-decode'

export default class JWT extends Middleware

	handle: (app, next) ->
		if app.input and app.input.token
			try
				app.token = jwtDecode app.input.token
			catch error
				throw new Error '[400] JWT Decoding Error'

		await next()
