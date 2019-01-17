
import ExtendableError from './extendable-error'

export default class ViewableError extends ExtendableError

	constructor: (message) ->
		super '[viewable] ' + message
