import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  HealthProfile,
  HealthProfileSchema,
} from './schemas/healthProfile.schema';
import { HealthProfileController } from './healthProfile.controller';
import { HealthProfileService } from './healthProfile.service';
import { HealthProfileRepository } from './healthProfile.repository';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: HealthProfile.name, schema: HealthProfileSchema },
    ]),
  ],
  controllers: [HealthProfileController],
  providers: [HealthProfileService, HealthProfileRepository],
  exports: [HealthProfileService],
})
export class HealthProfileModule {}
