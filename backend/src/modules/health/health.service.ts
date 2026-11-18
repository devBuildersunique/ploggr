import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { DataSource } from 'typeorm';

export interface Readiness {
  status: 'ok';
  database: 'up';
  postgis: 'up';
}

@Injectable()
export class HealthService {
  constructor(private readonly database: DataSource) {}

  async readiness(): Promise<Readiness> {
    try {
      // One read-only statement, bounded by the shared pool/query/statement timeouts.
      const [probe]: { connection: number; postgis: string; srid: number }[] = await this.database.query(`
        SELECT 1 AS connection, PostGIS_Version() AS postgis,
          ST_SRID(ST_SetSRID(ST_MakePoint(0, 0), 4326)) AS srid
      `);
      if (probe?.connection !== 1 || !probe.postgis || probe.srid !== 4326) {
        throw new Error('Dependency check did not pass');
      }
      return { status: 'ok', database: 'up', postgis: 'up' };
    } catch {
      // Keep driver messages and server metadata out of both HTTP responses and logs.
      throw new ServiceUnavailableException('Database readiness check failed');
    }
  }
}
