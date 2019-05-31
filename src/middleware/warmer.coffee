
import Middleware from './abstract'

export default class Warmer extends Middleware

	handle: (app, next) ->

		input = app.input

		if (
			typeof input is 'object' and
			input.warmer
		)
			message = 'Warming...'
			console.log message
			app.output = message
			return

		await next()
