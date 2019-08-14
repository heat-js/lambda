
import AWS from 'aws-sdk'

export default class AbstractMiddleware

	handle: (app, next) ->
		await next()

	setAwsCredentials: (app) ->
		AWS.CredentialProviderChain.defaultProviders = [
			-> return new AWS.EnvironmentCredentials('AWS')
			-> return new AWS.EnvironmentCredentials('AMAZON')
		]

		chain = new AWS.CredentialProviderChain

		if app.has 'awsCredentials'
			provider = app.awsCredentials
			chain.providers.unshift provider

		cred = await chain.resolvePromise()

		AWS.config.credentials = cred
