
import Middleware from './abstract'

export default class Warmer extends Middleware

	handle: (app, next) ->

		input = app.input

		if (
			typeof input is 'object' and
			input.warmer
		)
			console.log 'Warming...'
			return

		await next()
