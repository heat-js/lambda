
import Container 	from '@heat/container'
import compose 		from './compose'

export default (middlewares...) ->

	fn = compose middlewares

	return (input, context) ->
		app = Container.proxy()
		app.context = context
		app.input 	= input

		return await fn app
