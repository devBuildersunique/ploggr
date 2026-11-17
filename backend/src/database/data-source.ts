import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { createDatabaseOptions, loadDatabaseEnvironment } from './database.config';

// TypeORM CLI loads this without bootstrapping NestJS. The same options are used by Nest.
export default new DataSource(createDatabaseOptions(loadDatabaseEnvironment()));
