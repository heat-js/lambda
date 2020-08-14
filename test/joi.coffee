
import joi 		from '@hapi/joi'
import handle 	from '../src/handle'
import Joi 		from '../src/middleware/joi'

describe 'Test Worker Middleware', ->

	it 'should return lowercase username', ->
		lambda = handle(
			new Joi {
				username: joi.string().max(25).lowercase().required()
			}
			(app) ->
				app.output = app.input.username
		)

		expect await lambda { username: 'Test' }
			.toBe 'test'
