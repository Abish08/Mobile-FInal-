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
import { WorkoutLogService } from '../services/workoutLog.service';
import type { AuthenticatedRequest } from '../common/types/authenticated-request.type';

type CreateWorkoutLogBody = {
  workoutId?: string;
  duration?: number;
  date?: string;
};

@Controller('workoutLogs')
@UseGuards(AuthGuard('jwt'))
export class WorkoutLogController {
  constructor(private readonly workoutLogService: WorkoutLogService) {}

  @Post()
  async createLog(
    @Req() req: AuthenticatedRequest,
    @Body() body: CreateWorkoutLogBody,
  ) {
    const userId = req.user._id.toString();
    const { workoutId, duration, date } = body;
    if (!workoutId) {
      throw new BadRequestException('Missing required fields');
    }

    const logDate = date ? new Date(date) : new Date();
    const log = await this.workoutLogService.createLog(
      userId,
      workoutId,
      duration,
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
    const logs = await this.workoutLogService.getUserLogs(userId, date);
    const summary = await this.workoutLogService.getDailySummary(userId, date);
    return { success: true, data: logs, summary };
  }

  @Delete(':id')
  async deleteLog(@Req() req: AuthenticatedRequest, @Param('id') id: string) {
    await this.workoutLogService.deleteLog(id, req.user._id.toString());
    return { success: true, message: 'Log deleted successfully' };
  }
}
