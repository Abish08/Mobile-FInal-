import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Food, FoodDocument } from './schemas/food.schema';

@Injectable()
export class FoodsService {
  constructor(@InjectModel(Food.name) private foodModel: Model<FoodDocument>) {}

  async findAll(search?: string, category?: string) {
    const query: any = {};
    
    if (search) {
      query.name = { $regex: search, $options: 'i' };
    }
    if (category && category !== 'all') {
      query.category = category;
    }

    const foods = await this.foodModel.find(query).sort({ createdAt: -1 });
    const totalItems = await this.foodModel.countDocuments();
    const pendingApproval = await this.foodModel.countDocuments({ isApproved: false });

    return {
      success: true,
      foods,
      totalItems,
      pendingApproval,
    };
  }

  async getAdminStats() {
    const totalItems = await this.foodModel.countDocuments();
    const pendingApproval = await this.foodModel.countDocuments({ isApproved: false });
    
    return { 
      success: true, 
      stats: { totalItems, pendingApproval } 
    };
  }

  async create(createFoodDto: any) {
    const createdFood = await this.foodModel.create(createFoodDto);
    return { success: true, data: createdFood };
  }

  async findOne(id: string) {
    const food = await this.foodModel.findById(id);
    if (!food) throw new NotFoundException('Food not found');
    return { success: true, data: food };
  }

  async update(id: string, updateFoodDto: any) {
    const updatedFood = await this.foodModel.findByIdAndUpdate(id, updateFoodDto, { new: true });
    if (!updatedFood) throw new NotFoundException('Food not found');
    return { success: true, data: updatedFood };
  }

  // ✅ NEW: Update thumbnail for existing food
  async updateThumbnail(id: string, thumbnailPath: string) {
    const food = await this.foodModel.findById(id);
    if (!food) throw new NotFoundException('Food not found');

    food.thumbnail = thumbnailPath;
    await food.save();

    return { success: true, data: food };
  }

  // ✅ Add additional images
  async addImages(id: string, imagePaths: string[]) {
    const food = await this.foodModel.findById(id);
    if (!food) throw new NotFoundException('Food not found');

    const existingImages = food.images || [];
    food.images = [...existingImages, ...imagePaths];
    await food.save();

    return { success: true, data: food };
  }

  async remove(id: string) {
    const deletedFood = await this.foodModel.findByIdAndDelete(id);
    if (!deletedFood) throw new NotFoundException('Food not found');
    return { success: true, message: 'Food deleted successfully' };
  }
}