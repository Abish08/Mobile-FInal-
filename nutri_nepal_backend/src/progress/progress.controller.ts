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
} from '@nestjs/common';
import { ProgressService } from './progress.service';
import { CreateProgressDto } from './dto/create-progress.dto';
import { UpdateProgressDto } from './dto/update-progress.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ParseObjectIdPipe } from '../common/pipes/parse-object-id.pipe';
import type { UserDocument } from '../users/schemas/user.schema';

@Controller('progress')
@UseGuards(JwtAuthGuard)
export class ProgressController {
  constructor(private readonly progressService: ProgressService) {}

  @Post()
  async create(
    @Body() dto: CreateProgressDto,
    @CurrentUser() user: UserDocument,
  ) {
    return {
      success: true,
      data: await this.progressService.create({
        ...dto,
        userId: user._id.toString(),
      }),
    };
  }

  @Get()
  async findAll(@CurrentUser() user: UserDocument) {
    return {
      success: true,
      data: await this.progressService.findAll(user._id.toString()),
    };
  }

  @Get('history/calories')
  async getCalorieHistory(
    @CurrentUser() user: UserDocument,
    @Query('days') days?: string,
  ) {
    const parsedDays = days ? Number(days) : 30;
    const history = await this.progressService.findHistory(
      user._id.toString(),
      Number.isFinite(parsedDays) ? parsedDays : 30,
    );

    return {
      success: true,
      data: history.map((item) => ({
        _id: item.date.toISOString().substring(0, 10),
        calories: item.weight,
        weight: item.weight,
        date: item.date,
      })),
    };
  }

  @Get('history/workouts')
  getWorkoutHistory() {
    return { success: true, data: [] };
  }

  @Get('summary')
  async getSummary(@CurrentUser() user: UserDocument) {
    return {
      success: true,
      data: await this.progressService.getSummary(user._id.toString()),
    };
  }

  @Get(':id')
  async findOne(@Param('id', ParseObjectIdPipe) id: string) {
    return { success: true, data: await this.progressService.findById(id) };
  }

  @Put(':id')
  async update(
    @Param('id', ParseObjectIdPipe) id: string,
    @Body() dto: UpdateProgressDto,
  ) {
    return { success: true, data: await this.progressService.update(id, dto) };
  }

  @Delete(':id')
  async remove(@Param('id', ParseObjectIdPipe) id: string) {
    await this.progressService.remove(id);
    return { success: true, message: 'Progress deleted' };
  }
}
