import * as AWS from 'aws-sdk'
const logs = new AWS.CloudWatchLogs({ region: process.env.AWS_REGION })

export async function getLogsWithPrefix (logGroupNamePrefix: string): Promise<string[]> {
  const response = await logs.describeLogGroups({ logGroupNamePrefix }).promise()
  return response.logGroups
    ? response.logGroups
      .map((logGroup) => logGroup.logGroupName)
      .filter(x => x) as string[]
    : []
}

export async function isSubscribed (logGroupName: string): Promise<boolean> {
  const response = await logs.describeSubscriptionFilters({ logGroupName }).promise()
  return response.subscriptionFilters ? response.subscriptionFilters.length > 0 : false
}

export async function putSubscription (logGroupName: string, destinationArn: string):
Promise<unknown> {
  const params = {
    filterName: `${logGroupName}-filter`,
    filterPattern: '',
    destinationArn,
    logGroupName
  }
  return logs.putSubscriptionFilter(params).promise()
}
