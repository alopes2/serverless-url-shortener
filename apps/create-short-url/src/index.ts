import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  DeleteCommand,
  PutCommand,
} from '@aws-sdk/lib-dynamodb';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import Hashids from 'hashids';

const tableName = 'Movies';
const idSalt: string = process.env.SALT || '';
const baseUrl: string = process.env.BASE_URL || '';

type ShortUrlRequest = {
  url: string;
};

type Response = {
  id: string;
  shortUrl: string;
  url: string;
};

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  let request: ShortUrlRequest;

  try {
    request = JSON.parse(event.body || '{}');
  } catch {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'Invalid request body',
      }),
    };
  }

  if (!request || !request.url) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: 'URL is required',
      }),
    };
  }

  console.log('Processing request ', request);

  const client = new DynamoDBClient({});
  const docClient = DynamoDBDocumentClient.from(client);

  const hashID = new Hashids(idSalt, 6);
  const id = crypto.randomUUID();
  const code = hashID.encode(id);

  const command = new PutCommand({
    TableName: tableName,
    Item: {
      ID: id,
      Code: code,
      URL: request.url,
    },
  });

  try {
    await docClient.send(command);

    const response: Response = {
      id: id,
      shortUrl: baseUrl + hashID,
      url: request.url,
    };

    return {
      statusCode: 204,
      body: JSON.stringify(response),
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
