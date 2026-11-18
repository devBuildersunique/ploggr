import { Controller, Get, Header } from '@nestjs/common';
import { HealthService, type Readiness } from './health.service';

@Controller('health')
export class HealthController {
  constructor(private readonly health: HealthService) {}

  @Get()
  check(): { status: 'ok' } {
    return { status: 'ok' };
  }

  @Get('ready')
  @Header('Cache-Control', 'no-store')
  readiness(): Promise<Readiness> {
    return this.health.readiness();
  }
}
