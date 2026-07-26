import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { WorkoutLog, WorkoutLogSchema } from '../models/workoutLog.model';
import { Workout, WorkoutSchema } from './schemas/workout.schema';
import { WorkoutLogController } from '../controllers/workoutLog.controller';
import { WorkoutLogService } from '../services/workoutLog.service';
import { WorkoutLogRepository } from '../repositories/workoutLog.repository';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: WorkoutLog.name, schema: WorkoutLogSchema },
      { name: Workout.name, schema: WorkoutSchema },
    ]),
  ],
  controllers: [WorkoutLogController],
  providers: [WorkoutLogService, WorkoutLogRepository],
  exports: [WorkoutLogService],
})
export class WorkoutLogsModule {}
