
import Container 	from '@heat/container'
import compose 		from './compose'

handle = (middlewares...) ->

	fn = compose middlewares

	return (input, context) ->
		app = handle.container()
		app.context = context
		app.input 	= input

		await fn app

		return app.output

handle.container = ->

	return Container.proxy()

export default handle
