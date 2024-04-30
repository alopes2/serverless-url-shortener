import AWS from 'aws-sdk';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
// @ts-ignore
import AmazonDaxClient from 'amazon-dax-client';

const tableName = 'urls';
const redirectCodeParam = 'redirectCode';

const daxEndpoint = `dax://${process.env.DAX_ENDPOINT}`;

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  if (!event.pathParameters || !event.pathParameters[redirectCodeParam]) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Redirect code missing',
      }),
    };
  }

  let redirectCode: string = event.pathParameters[redirectCodeParam];

  console.log('Processing request code ', redirectCode);

  var dax = new AmazonDaxClient({
    endpoints: [daxEndpoint!],
  });
  var client = new AWS.DynamoDB.DocumentClient({ service: dax });

  try {
    const dynamoResponse = await client
      .query({
        TableName: tableName,
        IndexName: 'CodeIndex',
        KeyConditionExpression: 'Code = :code',
        ExpressionAttributeValues: {
          ':code': redirectCode,
        },
      })
      .promise();

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
