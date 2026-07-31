import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Progress, ProgressDocument } from './schemas/progress.schema';
import { CreateProgressDto } from './dto/create-progress.dto';
import { UpdateProgressDto } from './dto/update-progress.dto';
import { FoodLog, FoodLogDocument } from '../models/foodLog.model';
import { WorkoutLog, WorkoutLogDocument } from '../models/workoutLog.model';

@Injectable()
export class ProgressService {
  constructor(
    @InjectModel(Progress.name) private progressModel: Model<ProgressDocument>,
    @InjectModel(FoodLog.name) private foodLogModel: Model<FoodLogDocument>,
    @InjectModel(WorkoutLog.name)
    private workoutLogModel: Model<WorkoutLogDocument>,
  ) {}

  async create(dto: CreateProgressDto) {
    return this.progressModel.create(dto);
  }

  async findAll(userId: string) {
    return this.progressModel.find({ userId }).sort({ date: -1 });
  }

  async findHistory(userId: string, days = 30) {
    const since = new Date();
    since.setDate(since.getDate() - days);

    return this.progressModel
      .find({ userId, date: { $gte: since } })
      .sort({ date: 1 });
  }

  async getCalorieHistory(userId: string, days = 30) {
    const since = this.since(days);

    return this.foodLogModel.aggregate([
      {
        $match: {
          userId: new Types.ObjectId(userId),
          date: { $gte: since },
        },
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$date' } },
          calories: { $sum: '$totalCalories' },
          protein: { $sum: '$totalProtein' },
          carbs: { $sum: '$totalCarbs' },
          fats: { $sum: '$totalFats' },
          date: { $min: '$date' },
        },
      },
      { $sort: { date: 1 } },
    ]);
  }

  async getWorkoutHistory(userId: string, days = 30) {
    const since = this.since(days);

    return this.workoutLogModel.aggregate([
      {
        $match: {
          userId: new Types.ObjectId(userId),
          $or: [{ date: { $gte: since } }, { createdAt: { $gte: since } }],
        },
      },
      {
        $addFields: {
          chartDate: { $ifNull: ['$date', '$createdAt'] },
        },
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$chartDate' } },
          calories: { $sum: '$caloriesBurned' },
          duration: { $sum: '$duration' },
          date: { $min: '$chartDate' },
        },
      },
      { $sort: { date: 1 } },
    ]);
  }

  async getSummary(userId: string) {
    const history = await this.progressModel
      .find({ userId })
      .sort({ date: 1 })
      .limit(100);

    const first = history[0];
    const latest = history[history.length - 1];

    return {
      totalEntries: history.length,
      startWeight: first?.weight ?? null,
      currentWeight: latest?.weight ?? null,
      weightChange:
        first && latest ? Number((latest.weight - first.weight).toFixed(2)) : 0,
    };
  }

  async findById(id: string) {
    const progress = await this.progressModel.findById(id);
    if (!progress) throw new NotFoundException('Progress not found');
    return progress;
  }

  async update(id: string, dto: UpdateProgressDto) {
    const updated = await this.progressModel.findByIdAndUpdate(id, dto, {
      returnDocument: 'after',
    });
    if (!updated) throw new NotFoundException('Progress not found');
    return updated;
  }

  async remove(id: string) {
    const deleted = await this.progressModel.findByIdAndDelete(id);
    if (!deleted) throw new NotFoundException('Progress not found');
  }

  private since(days = 30) {
    const since = new Date();
    since.setHours(0, 0, 0, 0);
    since.setDate(since.getDate() - days);
    return since;
  }
}
