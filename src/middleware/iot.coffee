
import Middleware	from './abstract'
import AWS			from 'aws-sdk'

export default class Iot extends Middleware

	endpoint: (app) ->
		return (
			app.has('config') and
			app.config.iot and
			app.config.iot.endpoint
		) or (
			process.env.IOT_ENDPOINT
		) or (
			await @describeEndpoint()
		)

	describeEndpoint: (app) ->
		if not @promise
			@promise = app.iot.describeEndpoint {
				endpointType: 'iot:Data'
			}
			.promise()

		{ endpointAddress } = await @promise
		return endpointAddress

	handle: (app, next) ->
		app.iot = ->
			return new AWS.Iot {
				apiVersion: '2015-05-28'
			}

		endpoint = await @endpoint app

		app.iotData = ->
			return new AWS.IotData {
				endpoint
				apiVersion: '2015-05-28'
			}

		app.webSocket = ->
			return new WebSocket app.iotData

		await next()

export class WebSocket

	constructor: (@iotData) ->

	send: ({ topic, id, event, payload, qos: 1 }) ->
		data =
			e: event
			v: payload

		if id
			data.i = id

		await @iotData.publish {
			qos
			topic
			payload: JSON.stringify data
		}
		.promise()