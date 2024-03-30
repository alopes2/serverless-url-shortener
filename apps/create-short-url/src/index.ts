import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

const tableName = 'urls';
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

  const id = crypto.randomUUID();
  const code = generateCode();

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
      shortUrl: baseUrl + code,
      url: request.url,
    };

    return {
      statusCode: 201,
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

function generateCode(): string {
  const alphabet =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const length = 7;

  var code: string[] = [];

  for (var i = 0; i < length; i++) {
    var randomIndex: number = Math.round(Math.random() * alphabet.length);

    code[i] = alphabet[randomIndex];
  }

  return code.join('');
}
