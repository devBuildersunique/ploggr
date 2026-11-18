import { Body, Controller, Get, Global, INestApplication, Logger, Module, Post } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { Test } from '@nestjs/testing';
import { IsString, MinLength } from 'class-validator';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { DatabaseModule } from '../src/database/database.module';

const query = jest.fn();

@Global()
@Module({ providers: [{ provide: DataSource, useValue: { query } }], exports: [DataSource] })
class TestDatabaseModule {}

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
    }).overrideModule(DatabaseModule).useModule(TestDatabaseModule).compile();
    app = module.createNestApplication();
    configureApp(app);
    await app.init();
  });

  afterAll(async () => {
    await app?.close();
  });

  beforeEach(() => {
    query.mockReset();
    query.mockResolvedValue([{ connection: 1, postgis: '3.7', srid: 4326 }]);
  });

  it('GET /api/health returns HTTP 200 with JSON status', async () => {
    await request(app.getHttpServer())
      .get('/api/health')
      .expect('Content-Type', /json/)
      .expect(200, { status: 'ok' });
    expect(query).not.toHaveBeenCalled();
  });

  it('checks real dependency capabilities for every readiness request without exposing versions', async () => {
    for (let attempt = 0; attempt < 2; attempt++) {
      await request(app.getHttpServer()).get('/api/health/ready')
        .expect('Cache-Control', 'no-store')
        .expect(200, { status: 'ok', database: 'up', postgis: 'up' });
    }
    expect(query).toHaveBeenCalledTimes(2);
  });

  it.each([
    new Error('private_driver_details password=private_password'),
    [{ connection: 1, postgis: '', srid: 4326 }],
    [{ connection: 1, postgis: '3.7', srid: 0 }],
    [],
  ])('returns sanitized 503 errors when readiness fails: case %#', async (result) => {
    const log = jest.spyOn(Logger.prototype, 'error').mockImplementation(() => undefined);
    try {
      if (result instanceof Error) query.mockRejectedValueOnce(result);
      else query.mockResolvedValueOnce(result);
      const response = await request(app.getHttpServer()).get('/api/health/ready').expect(503);
      expect(response.headers['cache-control']).toBe('no-store');
      expect(response.body).toEqual({
        statusCode: 503, error: 'Service Unavailable', message: 'Internal server error',
        path: '/api/health/ready', timestamp: expect.any(String),
      });
      expect(JSON.stringify(response.body)).not.toContain('private_');
      expect(JSON.stringify(log.mock.calls)).not.toContain('private_');
      await request(app.getHttpServer()).get('/api/health').expect(200, { status: 'ok' });
    } finally {
      log.mockRestore();
    }
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
