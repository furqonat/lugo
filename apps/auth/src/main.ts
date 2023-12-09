import { Server } from 'http'
import { APIGatewayEvent, Context } from 'aws-lambda'
import * as serverlessExpress from 'aws-serverless-express'
import express, { Express } from 'express'

import { ValidationPipe } from '@nestjs/common'
import { NestFactory } from '@nestjs/core'

import { AppModule } from './app/app.module'
import { ExpressAdapter } from '@nestjs/platform-express'

let lambdaProxy: Server

async function bootstrap() {
  const expressServer: Express = express()
  const app = await NestFactory.create(
    AppModule,
    new ExpressAdapter(expressServer),
  )
  app.useGlobalPipes(new ValidationPipe())
  app.enableCors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    preflightContinue: false,
    optionsSuccessStatus: 200,
  })
  await app.init()
  return serverlessExpress.createServer(expressServer, null, [])
  // const port = process.env.PORT || 3333
  // await app.listen(port)
  // // Logger.log(
  // //   `🚀 Application is running on: http://localhost:${port}/${globalPrefix}`
  // // )
}

bootstrap().then((server) => (lambdaProxy = server))

function waitForServer(event: APIGatewayEvent, context: Context) {
  setImmediate(() => {
    if (!lambdaProxy) {
      waitForServer(event, context)
    } else {
      serverlessExpress.proxy(lambdaProxy, event, context)
    }
  })
}

export const handler = (event: APIGatewayEvent, context: Context) => {
  if (lambdaProxy) {
    serverlessExpress.proxy(lambdaProxy, event, context)
  } else {
    waitForServer(event, context)
  }
}
