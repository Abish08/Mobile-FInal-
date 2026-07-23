import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards, Query, UseInterceptors, UploadedFile, UploadedFiles } from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { WorkoutsService } from './workouts.service';
import { CreateWorkoutDto } from './dto/create-workout.dto';
import { UpdateWorkoutDto } from './dto/update-workout.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { AdminGuard } from '../common/guards/admin.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ParseObjectIdPipe } from '../common/pipes/parse-object-id.pipe';

@Controller('workouts')
@UseGuards(JwtAuthGuard)
export class WorkoutsController {
  constructor(private readonly workoutsService: WorkoutsService) {}

  // --- USER ENDPOINTS ---
  @Post()
  async create(@Body() dto: CreateWorkoutDto, @CurrentUser() user: any) {
    return { success: true, data: await this.workoutsService.create({ ...dto, userId: user._id }) };
  }

  @Get()
  async findAll(@CurrentUser() user: any) {
    return { success: true, data: await this.workoutsService.findAll(user._id.toString()) };
  }

  @Get(':id')
  async findOne(@Param('id', ParseObjectIdPipe) id: string) {
    return { success: true, data: await this.workoutsService.findById(id) };
  }

  @Put(':id')
  async update(@Param('id', ParseObjectIdPipe) id: string, @Body() dto: UpdateWorkoutDto) {
    return { success: true, data: await this.workoutsService.update(id, dto) };
  }

  @Delete(':id')
  async remove(@Param('id', ParseObjectIdPipe) id: string) {
    await this.workoutsService.remove(id);
    return { success: true, message: 'Workout deleted' };
  }

  // --- ADMIN ENDPOINTS ---
  @Get('admin/all')
  @UseGuards(AdminGuard)
  async getAllWorkouts(
    @Query('search') search?: string,
    @Query('category') category?: string,
  ) {
    return this.workoutsService.findAllAdmin(search, category);
  }

  @Post('admin')
  @UseGuards(AdminGuard)
  async createAdminWorkout(@Body() dto: any) {
    return this.workoutsService.createAdminWorkout(dto);
  }

  @Put('admin/:id')
  @UseGuards(AdminGuard)
  async updateAdminWorkout(@Param('id') id: string, @Body() dto: any) {
    return this.workoutsService.updateAdminWorkout(id, dto);
  }

  @Delete('admin/:id')
  @UseGuards(AdminGuard)
  async deleteAdminWorkout(@Param('id') id: string) {
    return this.workoutsService.deleteAdminWorkout(id);
  }

  // ✅ NEW: IMAGE UPLOAD ENDPOINTS
  @Post(':id/upload-thumbnail')
  @UseGuards(AdminGuard)
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
  async uploadThumbnail(
    @Param('id') id: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    const thumbnailPath = `/uploads/${file.filename}`;
    return this.workoutsService.updateThumbnail(id, thumbnailPath);
  }

  @Post(':id/upload-images')
  @UseGuards(AdminGuard)
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
  async uploadImages(
    @Param('id') id: string,
    @UploadedFiles() files: Array<Express.Multer.File>,
  ) {
    const imagePaths = files.map(file => `/uploads/${file.filename}`);
    return this.workoutsService.addImages(id, imagePaths);
  }
}