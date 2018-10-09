
import ExtendableError from './extendable-error'

export default class ViewableError extends ExtendableError

	viewable: true

	getData: -> {
		error:
			type:		@name
			message: 	@message
			viewable: 	@viewable
	}
