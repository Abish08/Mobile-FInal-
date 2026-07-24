import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards, Query, UseInterceptors, UploadedFile, UploadedFiles } from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { WorkoutsService } from './workouts.service';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { AdminGuard } from '../common/guards/admin.guard';
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ParseObjectIdPipe } from '../common/pipes/parse-object-id.pipe';

@Controller('workouts') // ⚠️ NO @UseGuards HERE
export class WorkoutsController {
  constructor(private readonly workoutsService: WorkoutsService) {}

  // ✅ 1. FOOLPROOF TEST ENDPOINT (No guards, no decorators)
  @Get('test')
  testEndpoint() {
    return { message: 'SUCCESS! This endpoint is 100% public and has no guards.' };
  }

  // ✅ 2. CATALOG ENDPOINT (With @Public to bypass any hidden guards)
  @Get('catalog')
  @Public()
  async getWorkoutCatalog() {
    console.log('🚀 CATALOG HIT');
    const result = await this.workoutsService.findAllAdmin();
    return {
      success: true,
      workouts: result.workouts,
      totalItems: result.totalItems
    };
  }

  // --- PROTECTED ENDPOINTS (Guards applied individually) ---
  @Post()
  @UseGuards(JwtAuthGuard)
  async create(@Body() dto: CreateWorkoutDto, @CurrentUser() user: any) {
    return { success: true, data: await this.workoutsService.create({ ...dto, userId: user._id }) };
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  async findAll(@CurrentUser() user: any) {
    return { success: true, data: await this.workoutsService.findAll(user._id.toString()) };
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  async findOne(@Param('id', ParseObjectIdPipe) id: string) {
    return { success: true, data: await this.workoutsService.findById(id) };
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  async update(@Param('id', ParseObjectIdPipe) id: string, @Body() dto: UpdateWorkoutDto) {
    return { success: true, data: await this.workoutsService.update(id, dto) };
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async remove(@Param('id', ParseObjectIdPipe) id: string) {
    await this.workoutsService.remove(id);
    return { success: true, message: 'Workout deleted' };
  }

  @Get('admin/all')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async getAllWorkouts(@Query('search') search?: string, @Query('category') category?: string) {
    return this.workoutsService.findAllAdmin(search, category);
  }

  @Post('admin')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async createAdminWorkout(@Body() dto: any) {
    return this.workoutsService.createAdminWorkout(dto);
  }

  @Put('admin/:id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async updateAdminWorkout(@Param('id') id: string, @Body() dto: any) {
    return this.workoutsService.updateAdminWorkout(id, dto);
  }

  @Delete('admin/:id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async deleteAdminWorkout(@Param('id') id: string) {
    return this.workoutsService.deleteAdminWorkout(id);
  }

  @Post(':id/upload-thumbnail')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @UseInterceptors(FileInterceptor('thumbnail', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, callback) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = extname(file.originalname);
        callback(null, `workout-${uniqueSuffix}${ext}`);
      },
    }),
  }))
  async uploadThumbnail(@Param('id') id: string, @UploadedFile() file: Express.Multer.File) {
    return this.workoutsService.updateThumbnail(id, `/uploads/${file.filename}`);
  }

  @Post(':id/upload-images')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @UseInterceptors(FilesInterceptor('images', 5, {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, callback) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = extname(file.originalname);
        callback(null, `workout-${uniqueSuffix}${ext}`);
      },
    }),
  }))
  async uploadImages(@Param('id') id: string, @UploadedFiles() files: Array<Express.Multer.File>) {
    const imagePaths = files.map(file => `/uploads/${file.filename}`);
    return this.workoutsService.addImages(id, imagePaths);
  }
}