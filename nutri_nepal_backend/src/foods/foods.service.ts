import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, QueryFilter, UpdateQuery } from 'mongoose';
import { Food, FoodDocument } from './schemas/food.schema';

type FoodMediaValue =
  | string
  | {
      url?: string;
      publicId?: string;
    }
  | null
  | undefined;

type FoodResponse = Omit<Partial<Food>, 'thumbnail' | 'images'> & {
  _id?: unknown;
  thumbnail?: string;
  images?: string[];
};

@Injectable()
export class FoodsService {
  constructor(@InjectModel(Food.name) private foodModel: Model<FoodDocument>) {}

  async findAll(search?: string, category?: string) {
    const query: QueryFilter<FoodDocument> = {};

    if (search) {
      query.name = { $regex: search, $options: 'i' };
    }
    if (category && category !== 'all') {
      query.category = category;
    }

    const foods = await this.foodModel
      .find(query)
      .sort({ createdAt: -1 })
      .lean();
    const totalItems = await this.foodModel.countDocuments();
    const pendingApproval = await this.foodModel.countDocuments({
      isApproved: false,
    });

    return {
      success: true,
      foods: foods.map((food) => this.toFoodResponse(food)),
      totalItems,
      pendingApproval,
    };
  }

  async getAdminStats() {
    const totalItems = await this.foodModel.countDocuments();
    const pendingApproval = await this.foodModel.countDocuments({
      isApproved: false,
    });

    return {
      success: true,
      stats: { totalItems, pendingApproval },
    };
  }

  async create(createFoodDto: Partial<Food>) {
    const createdFood = await this.foodModel.create(
      this.normalizeFoodInput(createFoodDto),
    );
    return { success: true, data: this.toFoodResponse(createdFood.toObject()) };
  }

  async findOne(id: string) {
    const food = await this.foodModel.findById(id).lean();
    if (!food) throw new NotFoundException('Food not found');
    return { success: true, data: this.toFoodResponse(food) };
  }

  async update(id: string, updateFoodDto: UpdateQuery<FoodDocument>) {
    const updatedFood = await this.foodModel
      .findByIdAndUpdate(
        id,
        this.normalizeFoodInput(updateFoodDto as Partial<Food>),
        { returnDocument: 'after' },
      )
      .lean();
    if (!updatedFood) throw new NotFoundException('Food not found');
    return { success: true, data: this.toFoodResponse(updatedFood) };
  }

  // ✅ NEW: Update thumbnail for existing food
  async updateThumbnail(id: string, thumbnailPath: string) {
    const food = await this.foodModel.findById(id);
    if (!food) throw new NotFoundException('Food not found');

    food.thumbnail = thumbnailPath;
    await food.save();

    return { success: true, data: this.toFoodResponse(food.toObject()) };
  }

  // ✅ Add additional images
  async addImages(id: string, imagePaths: string[]) {
    const food = await this.foodModel.findById(id);
    if (!food) throw new NotFoundException('Food not found');

    const existingImages = this.normalizeImages(food.images);
    food.images = [...existingImages, ...imagePaths];
    await food.save();

    return { success: true, data: this.toFoodResponse(food.toObject()) };
  }

  async remove(id: string) {
    const deletedFood = await this.foodModel.findByIdAndDelete(id);
    if (!deletedFood) throw new NotFoundException('Food not found');
    return { success: true, message: 'Food deleted successfully' };
  }

  private normalizeFoodInput(input: Partial<Food>): Partial<Food> {
    return {
      ...input,
      thumbnail: this.normalizeMedia(input.thumbnail as FoodMediaValue),
      images: this.normalizeImages(input.images),
    };
  }

  private toFoodResponse(
    food: Partial<Food> & { _id?: unknown },
  ): FoodResponse {
    return {
      ...food,
      thumbnail: this.normalizeMedia(food.thumbnail as FoodMediaValue),
      images: this.normalizeImages(food.images),
    };
  }

  private normalizeImages(value: unknown): string[] {
    if (!Array.isArray(value)) return [];
    return value
      .map((image) => this.normalizeMedia(image as FoodMediaValue))
      .filter((image): image is string => Boolean(image));
  }

  private normalizeMedia(value: FoodMediaValue): string | undefined {
    if (!value) return undefined;
    if (typeof value === 'string') return value;
    return value.url || value.publicId;
  }
}
