import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { WorkoutLog, WorkoutLogDocument } from '../models/workoutLog.model';

@Injectable()
export class WorkoutLogRepository {
  constructor(
    @InjectModel(WorkoutLog.name)
    private readonly workoutLogModel: Model<WorkoutLogDocument>,
  ) {}

  async create(logData: Partial<WorkoutLog>): Promise<WorkoutLogDocument> {
    const log = new this.workoutLogModel(logData);
    return await log.save();
  }

  async findByUserAndDate(
    userId: string,
    date: Date,
  ): Promise<WorkoutLogDocument[]> {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    return await this.workoutLogModel
      .find({
        userId: new Types.ObjectId(userId),
        date: { $gte: startOfDay, $lte: endOfDay },
      })
      .populate('workoutId', 'name category duration')
      .sort({ date: -1 });
  }

  async delete(id: string, userId: string): Promise<boolean> {
    if (!Types.ObjectId.isValid(id) || !Types.ObjectId.isValid(userId)) {
      return false;
    }
    const result = await this.workoutLogModel.findOneAndDelete({
      _id: new Types.ObjectId(id),
      userId: new Types.ObjectId(userId),
    });
    return !!result;
  }

  async getDailySummary(userId: string, date: Date) {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    const logs = await this.workoutLogModel.find({
      userId: new Types.ObjectId(userId),
      date: { $gte: startOfDay, $lte: endOfDay },
    });

    return logs.reduce(
      (acc, log) => {
        acc.duration += log.duration;
        acc.calories += log.caloriesBurned;
        return acc;
      },
      { duration: 0, calories: 0 },
    );
  }
}
