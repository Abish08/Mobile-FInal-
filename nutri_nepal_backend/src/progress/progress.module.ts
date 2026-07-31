import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Progress, ProgressSchema } from './schemas/progress.schema';
import { FoodLog, FoodLogSchema } from '../models/foodLog.model';
import { WorkoutLog, WorkoutLogSchema } from '../models/workoutLog.model';
import { ProgressController } from './progress.controller';
import { ProgressService } from './progress.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Progress.name, schema: ProgressSchema },
      { name: FoodLog.name, schema: FoodLogSchema },
      { name: WorkoutLog.name, schema: WorkoutLogSchema },
    ]),
  ],
  controllers: [ProgressController],
  providers: [ProgressService],
  exports: [ProgressService],
})
export class ProgressModule {}
