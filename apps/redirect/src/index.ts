import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, QueryCommand } from '@aws-sdk/lib-dynamodb';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { createClient } from 'redis';

const tableName = 'urls';
const redirectCodeParam = 'redirectCode';

const elasticachePort = +(process.env.ELASTICACHE_PORT || '6379');

console.log(
  'Redis URL %s in PORT %d',
  process.env.ELASTICACHE_URL,
  elasticachePort
);

const redisUrl = `redis://${process.env.ELASTICACHE_URL}:${elasticachePort}`;

console.log('Redis URL ', redisUrl);

// const redisClient = createClient({
//   username: process.env.REDIS_USERNAME,
//   password: process.env.REDIS_PASSWORD,
//   socket: {
//     host: process.env.ELASTICACHE_URL,
//     port: elasticachePort,
//     tls: true,
//   },
// });

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  // await redisClient.connect();

  if (!event.pathParameters || !event.pathParameters[redirectCodeParam]) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Redirect code missing',
      }),
    };
  }

  let redirectCode: string = event.pathParameters[redirectCodeParam];

  // var cachedUrl = await redisClient.get(redirectCode);

  // if (cachedUrl) {
  //   return {
  //     statusCode: 302,
  //     headers: {
  //       Location: cachedUrl, // For simplicity, let's say the first is our expected URL
  //     },
  //     body: '',
  //   };
  // }

  console.log('Processing request code ', redirectCode);

  const client = new DynamoDBClient({});
  const docClient = DynamoDBDocumentClient.from(client);

  const command = new QueryCommand({
    TableName: tableName,
    IndexName: 'CodeIndex',
    KeyConditionExpression: 'Code = :code',
    ExpressionAttributeValues: {
      ':code': redirectCode,
    },
  });

  try {
    const dynamoResponse = await docClient.send(command);

    if (!dynamoResponse.Items || dynamoResponse.Items.length == 0) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: 'URL not found',
        }),
      };
    }

    const url: string = dynamoResponse.Items[0].URL;

    console.log('Redirecting code %s to URL %s', redirectCode, url);

    // await redisClient.set(redirectCode, url);

    return {
      statusCode: 302,
      headers: {
        Location: url, // For simplicity, let's say the first is our expected URL
      },
      body: '',
    };
  } catch (e: any) {
    console.log(e);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: e.message,
      }),
    };
  }
};
