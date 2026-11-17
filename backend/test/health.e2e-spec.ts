import { Body, Controller, Get, INestApplication, Logger, Post } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { IsString, MinLength } from 'class-validator';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';

class ExampleDto {
  @IsString()
  @MinLength(2)
  name!: string;
}

// Test-only routes exercise shared policies without adding product endpoints.
@Controller('test')
class PolicyController {
  @Post()
  echo(@Body() body: ExampleDto): ExampleDto {
    return body;
  }

  @Get('error')
  fail(): never {
    throw new Error('private implementation detail');
  }
}

describe('API foundation (HTTP)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule],
      controllers: [PolicyController],
    }).compile();
    app = module.createNestApplication();
    configureApp(app);
    await app.init();
  });

  afterAll(async () => {
    await app?.close();
  });

  it('GET /api/health returns HTTP 200 with JSON status', async () => {
    await request(app.getHttpServer())
      .get('/api/health')
      .expect('Content-Type', /json/)
      .expect(200, { status: 'ok' });
  });

  it.each(['/health', '/api/missing'])('returns consistent 404 errors for %s', async (path) => {
    const response = await request(app.getHttpServer()).get(path).expect(404);
    expect(response.body).toEqual({
      statusCode: 404,
      error: 'Not Found',
      message: `Cannot GET ${path}`,
      path,
      timestamp: expect.any(String),
    });
    expect(Number.isNaN(Date.parse(response.body.timestamp))).toBe(false);
  });

  it('accepts valid DTO input', async () => {
    await request(app.getHttpServer())
      .post('/api/test')
      .send({ name: 'example' })
      .expect(201, { name: 'example' });
  });

  it.each([
    [{ name: 42 }, 'name must be a string'],
    [{ name: 'example', extra: true }, 'property extra should not exist'],
  ])('rejects invalid or unknown DTO fields: %j', async (body, message) => {
    const response = await request(app.getHttpServer())
      .post('/api/test')
      .send(body)
      .expect(400);
    expect(response.body).toEqual({
      statusCode: 400,
      error: 'Bad Request',
      message: expect.arrayContaining([message]),
      path: '/api/test',
      timestamp: expect.any(String),
    });
  });

  it('uses the same error shape for malformed JSON', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/test')
      .set('Content-Type', 'application/json')
      .send('{')
      .expect(400);
    expect(response.body).toEqual({
      statusCode: 400,
      error: 'Bad Request',
      message: expect.any(String),
      path: '/api/test',
      timestamp: expect.any(String),
    });
  });

  it('logs unexpected failures and hides internal details from clients', async () => {
    const log = jest.spyOn(Logger.prototype, 'error').mockImplementation(() => undefined);
    try {
      const response = await request(app.getHttpServer()).get('/api/test/error').expect(500);
      expect(response.body).toEqual({
        statusCode: 500,
        error: 'Internal Server Error',
        message: 'Internal server error',
        path: '/api/test/error',
        timestamp: expect.any(String),
      });
      expect(log).toHaveBeenCalled();
    } finally {
      log.mockRestore();
    }
  });
});
