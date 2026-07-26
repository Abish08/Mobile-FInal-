import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { WorkoutLog } from '../models/workoutLog.model';
import { Workout, WorkoutDocument } from '../workouts/schemas/workout.schema';
import { WorkoutLogRepository } from '../repositories/workoutLog.repository';

@Injectable()
export class WorkoutLogService {
  constructor(
    @InjectModel(Workout.name)
    private readonly workoutModel: Model<WorkoutDocument>,
    private readonly repo: WorkoutLogRepository,
  ) {}

  async createLog(
    userId: string,
    workoutId: string,
    duration: number | undefined,
    date: Date,
  ) {
    const workout = await this.workoutModel.findById(workoutId).exec();
    if (!workout) throw new NotFoundException('Workout not found');

    const loggedDuration =
      duration && duration > 0 ? duration : workout.duration || 30;
    const ratio = loggedDuration / (workout.duration || loggedDuration);
    const caloriesBurned = (workout.caloriesBurned || 0) * ratio;

    const logData: Partial<WorkoutLog> = {
      userId: new Types.ObjectId(userId),
      workoutId: new Types.ObjectId(workoutId),
      duration: loggedDuration,
      caloriesBurned,
      date,
    };

    return await this.repo.create(logData);
  }

  async getUserLogs(userId: string, date: Date) {
    return await this.repo.findByUserAndDate(userId, date);
  }

  async deleteLog(id: string, userId: string) {
    const deleted = await this.repo.delete(id, userId);
    if (!deleted) throw new NotFoundException('Log not found or delete failed');
    return true;
  }

  async getDailySummary(userId: string, date: Date) {
    return await this.repo.getDailySummary(userId, date);
  }
}
