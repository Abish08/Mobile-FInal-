import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  Req,
  UseGuards,
  BadRequestException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { FoodLogService } from '../services/foodLog.service';
import type { AuthenticatedRequest } from '../common/types/authenticated-request.type';

type CreateFoodLogBody = {
  foodId?: string;
  servings?: number;
  mealType?: string;
  date?: string;
};

@Controller('foodLogs')
@UseGuards(AuthGuard('jwt'))
export class FoodLogController {
  constructor(private readonly foodLogService: FoodLogService) {}

  @Post()
  async createLog(
    @Req() req: AuthenticatedRequest,
    @Body() body: CreateFoodLogBody,
  ) {
    const userId = req.user._id.toString();
    const { foodId, servings, mealType, date } = body;
    if (!foodId || !servings || !mealType)
      throw new BadRequestException('Missing required fields');

    const logDate = date ? new Date(date) : new Date();
    const log = await this.foodLogService.createLog(
      userId,
      foodId,
      servings,
      mealType,
      logDate,
    );
    return { success: true, data: log };
  }

  @Get()
  async getUserLogs(
    @Req() req: AuthenticatedRequest,
    @Query('date') dateStr: string,
  ) {
    const userId = req.user._id.toString();
    const date = dateStr ? new Date(dateStr) : new Date();
    const logs = await this.foodLogService.getUserLogs(userId, date);
    const summary = await this.foodLogService.getDailySummary(userId, date);
    return { success: true, data: logs, summary };
  }

  @Delete(':id')
  async deleteLog(@Req() req: AuthenticatedRequest, @Param('id') id: string) {
    await this.foodLogService.deleteLog(id, req.user._id.toString());
    return { success: true, message: 'Log deleted successfully' };
  }
}
