import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Meal, MealDocument } from './schemas/meal.schema';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';

@Injectable()
export class MealsService {
  constructor(@InjectModel(Meal.name) private mealModel: Model<MealDocument>) {}

  // USER METHODS (Keep existing functionality)


  async create(dto: any) { return this.mealModel.create(dto); }
  
  async findAll(userId: string) { 
    return this.mealModel.find({ userId }).sort({ eatenAt: -1 }); 
  }
  
  async findById(id: string) { 
    const meal = await this.mealModel.findById(id); 
    if (!meal) throw new NotFoundException('Meal not found'); 
    return meal; 
  }
  
  async update(id: string, dto: UpdateMealDto) { 
    const updated = await this.mealModel.findByIdAndUpdate(id, dto, { new: true }); 
    if (!updated) throw new NotFoundException('Meal not found'); 
    return updated; 
  }
  
  async remove(id: string) { 
    const deleted = await this.mealModel.findByIdAndDelete(id); 
    if (!deleted) throw new NotFoundException('Meal not found'); 
    return deleted; 
  }


  //  NEW: ADMIN METHODS (Food Management)
 

  async findAllAdmin(search?: string, category?: string) {
    const query: any = {};
    
    if (search) {
      query.name = { $regex: search, $options: 'i' };
    }
    if (category && category !== 'all') {
      query.category = category;
    }

    const meals = await this.mealModel.find(query).sort({ createdAt: -1 });
    const totalItems = await this.mealModel.countDocuments();
    
    // Note: If your Meal schema doesn't have a 'status' field yet, this will just return 0
    const pendingApproval = await this.mealModel.countDocuments({ status: 'pending' }); 

    return {
      success: true,
      meals,
      totalItems,
      pendingApproval,
    };
  }

  async getAdminStats() {
    const totalItems = await this.mealModel.countDocuments();
    const pendingApproval = await this.mealModel.countDocuments({ status: 'pending' });
    
    return { 
      success: true, 
      stats: { totalItems, pendingApproval } 
    };
  }
}