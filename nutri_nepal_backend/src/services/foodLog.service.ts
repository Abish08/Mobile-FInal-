import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { FoodLog } from '../models/foodLog.model';
import { Food, FoodDocument } from '../foods/schemas/food.schema';
import { FoodLogRepository } from '../repositories/foodLog.repository';

@Injectable()
export class FoodLogService {
  constructor(
    @InjectModel(Food.name)
    private readonly foodModel: Model<FoodDocument>,
    private readonly repo: FoodLogRepository,
  ) {}

  async createLog(
    userId: string,
    foodId: string,
    servings: number,
    mealType: string,
    date: Date,
  ) {
    const food = await this.foodModel.findById(foodId).exec();
    if (!food) throw new NotFoundException('Food not found');

    const logData: Partial<FoodLog> = {
      userId: new Types.ObjectId(userId),
      foodId: new Types.ObjectId(foodId),
      servings,
      mealType,
      date,
      totalCalories: food.calories * servings,
      totalProtein: food.protein * servings,
      totalCarbs: food.carbs * servings,
      totalFats: food.fats * servings,
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
