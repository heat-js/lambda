

import Middleware 	from './abstract'
import AWS			from 'aws-sdk'

export default class SqsMiddleware extends Middleware

	handle: (app, next) ->

		app.sqs = ->
			client = new AWS.SQS {
				apiVersion: '2012-11-05'
				region: app.config.aws.region
			}

			nameResolver = new SqsNameResolver client

			return new Sqs client, nameResolver

		await next()


class Sqs

	constructor: (@sqsClient, @sqsNameResolver) ->
		@cache = new Map

	send: (service, name, payload) ->
		queue = "#{service}__#{name}"

		return @sqsClient.sendMessage {
			QueueUrl: 		@sqsNameResolver.url queue
			MessageBody: 	JSON.stringify payload
			DelaySeconds: 	0
		}
		.promise()

	batch: (service, name, payloads = []) ->
		queue = "#{service}__#{name}"

		entries = []
		index = 0
		for payload in payloads
			entries.push {
				Id: 			String index++
				MessageBody: 	JSON.stringify payload
				DelaySeconds: 	0
			}

		promises = []
		chunks = @splitEntriesIntoChunks entries
		for entries in chunks
			promise = @sqsClient.sendMessageBatch {
				QueueUrl: @sqsNameResolver.url queue
				Entries: entries
			}
			.promise()

			promises.push promise

		await Promise.all promises

	splitEntriesIntoChunks: (entries, size = 10) ->
		chunkes = []
		while entries.length > 0
			chunkes.push entries.splice 0, size

		return chunkes


class SqsNameResolver

	constructor: (@sqsClient) ->
		@urls 		= new Map
		@promises 	= new Map

	url: (name) ->
		if @urls.has name
			return @urls.get name

		if @promises.has name
			{ QueueUrl } = await @promises.get name
			return QueueUrl

		request = @sqsClient.getQueueUrl {
			QueueName: name
		}

		promise = request.promise()

		@promises.set name, promise

		{ QueueUrl } = await promise

		@urls.set name, QueueUrl

		return QueueUrl

	# queueUrl: (name) ->
	# 	return "https://sqs.#{@region}.amazonaws.com/#{@accountId}/#{name}"
