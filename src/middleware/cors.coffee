
import Middleware 		from './abstract'
import ViewableError 	from '../error/viewable-error'

export default class Cors extends Middleware

	constructor: ({ @blocking = false, @origins }) ->
		super()

	getOrigins: (app) ->
		return (
			@origins or
			(
				app.has('config') and
				app.config.cors and
				app.config.cors.origins
			)
		)

	handle: (app, next) ->
		allowed = @getOrigins()
		origin 	= app.request.get 'origin'

		if origin and allowed.includes origin
			app.response.set 'access-control-expose-headers', [
				'content-length'
				'content-type'
			].join ','

			app.response.set 'access-control-allow-origin', origin
			# app.response.set 'access-control-allow-credentials', 'true'
			# app.response.set 'access-control-allow-headers', [
			# 	'content-type'
			# 	'x-token'
			# ].join ','

			await next()
			return

		if @blocking
			error = new ViewableError 'CORS origin not allowed'
			error.status = 403
			throw error

		await next()
