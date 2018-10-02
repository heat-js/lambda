
import Container 	from '@heat/container'
import compose 		from './compose'
import EventEmitter from 'events'

emitter = new EventEmitter

export default handle = (middlewares...) ->

	fn = compose middlewares

	return (input, context) ->
		app = Container.proxy()
		app.context = context
		app.input 	= input

		emitter.emit 'before', app

		await fn app

		emitter.emit 'after', app

		if app.has 'output'
			return app.output

handle.on = emitter.on.bind emitter
