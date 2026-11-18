import type { MigrationInterface, QueryRunner } from 'typeorm';

export class VerifyPostgis1794873600000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Provisioning installs the privileged extension before the application connects.
    await queryRunner.query('SELECT PostGIS_Full_Version()');
  }

  public async down(): Promise<void> {
    // PostGIS is shared infrastructure. Reverting this assertion must not drop it.
  }
}
