import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  Query,
  UseInterceptors,
  UploadedFile,
  UploadedFiles,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { FoodsService } from './foods.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { AdminGuard } from '../common/guards/admin.guard';
import { Public } from '../common/decorators/public.decorator';
import type { UpdateQuery } from 'mongoose';
import type { Food, FoodDocument } from './schemas/food.schema';

@Controller('foods')
export class FoodsController {
  constructor(private readonly foodsService: FoodsService) {}

  @Get('admin/all')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async getAllFoods(
    @Query('search') search?: string,
    @Query('category') category?: string,
  ) {
    return this.foodsService.findAll(search, category);
  }

  @Get('admin/stats')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async getAdminStats() {
    return this.foodsService.getAdminStats();
  }

  @Get()
  @Public()
  async getPublicFoods(
    @Query('search') search?: string,
    @Query('category') category?: string,
  ) {
    return this.foodsService.findAll(search, category);
  }

  // Create food (JSON only, no file upload here)
  @Post()
  @UseGuards(JwtAuthGuard, AdminGuard)
  async createFood(@Body() createFoodDto: Partial<Food>) {
    return this.foodsService.create(createFoodDto);
  }

  //  Upload thumbnail to existing food
  @Post(':id/upload-thumbnail')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @UseInterceptors(
    FileInterceptor('thumbnail', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, callback) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          callback(null, `food-${uniqueSuffix}${ext}`);
        },
      }),
    }),
  )
  async uploadThumbnail(
    @Param('id') id: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    const thumbnailPath = `/uploads/${file.filename}`;
    return this.foodsService.updateThumbnail(id, thumbnailPath);
  }

  // ✅ Upload additional images
  @Post(':id/upload-images')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @UseInterceptors(
    FilesInterceptor('images', 5, {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, callback) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          callback(null, `food-${uniqueSuffix}${ext}`);
        },
      }),
    }),
  )
  async uploadImages(
    @Param('id') id: string,
    @UploadedFiles() files: Array<Express.Multer.File>,
  ) {
    const imagePaths = files.map((file) => `/uploads/${file.filename}`);
    return this.foodsService.addImages(id, imagePaths);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async updateFood(
    @Param('id') id: string,
    @Body() updateFoodDto: UpdateQuery<FoodDocument>,
  ) {
    return this.foodsService.update(id, updateFoodDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async deleteFood(@Param('id') id: string) {
    return this.foodsService.remove(id);
  }

  @Get(':id')
  @Public()
  async getFoodById(@Param('id') id: string) {
    return this.foodsService.findOne(id);
  }
}
