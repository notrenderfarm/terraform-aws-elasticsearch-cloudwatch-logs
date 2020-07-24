import * as cloudwatch from './cloudwatch'
import { Handler } from 'aws-lambda'

export const handler: Handler = async () => {
  console.log('[terraform-aws-elasticsearch-lambdas] Automate subscription of CloudWatch logs')

  /* eslint-disable @typescript-eslint/no-non-null-assertion */
  const lambdaArn: string = process.env.LAMBDA_ARN!
  const cloudwatchLogsPrefixes: string[] = process.env.CLOUDWATCH_LOGS_PREFIXES!.split(',')
  /* eslint-enable @typescript-eslint/no-non-null-assertion */

  return Promise.all(
    cloudwatchLogsPrefixes.map(async prefix => {
      const logs = await cloudwatch.getLogsWithPrefix(prefix)
      return Promise.all(
        logs.map(async log => {
          if (!await cloudwatch.isSubscribed(log)) {
            console.log('[terraform-aws-elasticsearch-lambdas] Subscribing', log)
            return cloudwatch.putSubscription(log, lambdaArn)
          }
        }))
    })
  )
}
