import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { STATUS_CODES } from 'node:http';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();
    const request = context.getRequest<Request>();
    const response = context.getResponse<Response>();
    const statusCode = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    let message: string | string[] = 'Internal server error';
    const error = STATUS_CODES[statusCode] ?? 'Error';

    if (statusCode >= 500) {
      this.logger.error(exception);
    } else if (exception instanceof HttpException) {
      const body = exception.getResponse();
      message = typeof body === 'string'
        ? body
        : (body as { message?: string | string[] }).message ?? exception.message;
    }

    response.status(statusCode).json({
      statusCode,
      error,
      message,
      path: request.path,
      timestamp: new Date().toISOString(),
    });
  }
}
