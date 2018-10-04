
import Container 	from '@heat/container'
import compose 		from './compose'
import EventEmitter from 'events'

handle = (middlewares...) ->

	fn 		= compose middlewares
	emitter = new EventEmitter

	handle = (input, context) ->
		app = Container.proxy()
		app.context = context
		app.input 	= input

		emitter.emit 'before', app

		await fn app

		emitter.emit 'after', app

		handle.app = app

		if app.has 'output'
			return app.output

	handle.on = emitter.on.bind emitter
	handle.app = null

	return handle
