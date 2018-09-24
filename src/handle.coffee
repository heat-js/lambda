
import Container 	from '@heat/container'
import compose 		from './compose'

export default (middlewares...) ->

	fn = compose middlewares

	return (input, context) ->
		app = Container.proxy()
		app.context = context
		app.input 	= input

		await fn app

		if app.has 'output'
			return app.output
