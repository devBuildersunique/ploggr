import type { DataSource } from 'typeorm';

export interface DatabaseCheck {
  connectivity: true;
  postgresql: string;
  postgis: string;
  spatial: { type: 'Point'; coordinates: [number, number] };
}

export async function checkDatabase(source: DataSource): Promise<DatabaseCheck> {
  const [connection]: { value: number }[] = await source.query('SELECT 1 AS value');
  if (connection?.value !== 1) throw new Error('Database connectivity check failed');

  const [versions]: { postgresql: string; postgis: string }[] = await source.query(
    'SELECT version() AS postgresql, PostGIS_Full_Version() AS postgis',
  );
  const [point]: { spatial: DatabaseCheck['spatial'] }[] = await source.query(
    'SELECT ST_AsGeoJSON(ST_SetSRID(ST_MakePoint(78.4867, 17.385), 4326))::json AS spatial',
  );
  if (point?.spatial?.type !== 'Point' ||
      point.spatial.coordinates[0] !== 78.4867 || point.spatial.coordinates[1] !== 17.385) {
    throw new Error('PostGIS spatial check failed');
  }
  return { connectivity: true, ...versions, spatial: point.spatial };
}
