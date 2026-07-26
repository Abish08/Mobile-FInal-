import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { FoodLog, FoodLogDocument } from '../models/foodLog.model';

@Injectable()
export class FoodLogRepository {
  constructor(
    @InjectModel(FoodLog.name)
    private readonly foodLogModel: Model<FoodLogDocument>,
  ) {}

  async create(logData: Partial<FoodLog>): Promise<FoodLogDocument> {
    const log = new this.foodLogModel(logData);
    return await log.save();
  }

  async findByUserAndDate(
    userId: string,
    date: Date,
  ): Promise<FoodLogDocument[]> {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    return await this.foodLogModel
      .find({
        userId: new Types.ObjectId(userId),
        date: { $gte: startOfDay, $lte: endOfDay },
      })
      .populate('foodId', 'name category servingSize')
      .sort({ date: -1 });
  }

  async delete(id: string, userId: string): Promise<boolean> {
    if (!Types.ObjectId.isValid(id) || !Types.ObjectId.isValid(userId)) {
      return false;
    }
    const result = await this.foodLogModel.findOneAndDelete({
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

    const logs = await this.foodLogModel.find({
      userId: new Types.ObjectId(userId),
      date: { $gte: startOfDay, $lte: endOfDay },
    });

    return logs.reduce(
      (acc, log) => {
        acc.calories += log.totalCalories;
        acc.protein += log.totalProtein;
        acc.carbs += log.totalCarbs;
        acc.fats += log.totalFats;
        return acc;
      },
      { calories: 0, protein: 0, carbs: 0, fats: 0 },
    );
  }
}
