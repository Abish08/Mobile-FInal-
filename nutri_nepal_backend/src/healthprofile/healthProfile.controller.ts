import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Req,
  UseGuards,
} from '@nestjs/common';
import { HealthProfileService } from './healthProfile.service';
import { AuthGuard } from '@nestjs/passport';
import type { AuthenticatedRequest } from '../common/types/authenticated-request.type';

type HealthProfileBody = {
  weight?: number | string;
  height?: number | string;
  age?: number | string;
  gender?: string;
  activityLevel?: string;
  goal?: string;
  fitnessGoal?: string;
};

@Controller('healthProfile')
@UseGuards(AuthGuard('jwt'))
export class HealthProfileController {
  constructor(private readonly healthProfileService: HealthProfileService) {}

  @Post()
  async createOrUpdateProfile(
    @Req() req: AuthenticatedRequest,
    @Body() body: HealthProfileBody,
  ) {
    const userId = req.user._id.toString();
    const { weight, height, age, gender } = body;
    const activityLevel = body.activityLevel ?? 'moderate';
    const goal = body.goal ?? this.mapFitnessGoal(body.fitnessGoal);

    if (!weight || !height || !age || !gender || !activityLevel || !goal) {
      return { success: false, message: 'All fields are required' };
    }

    const profile = await this.healthProfileService.calculateAndUpdateProfile(
      userId,
      {
        weight: Number(weight),
        height: Number(height),
        age: Number(age),
        gender,
        activityLevel,
        goal,
      },
    );

    return {
      success: true,
      message: 'Health profile calculated and updated successfully',
      data: profile,
    };
  }

  @Patch()
  async patchProfile(
    @Req() req: AuthenticatedRequest,
    @Body() body: HealthProfileBody,
  ) {
    return this.createOrUpdateProfile(req, body);
  }

  @Get()
  async getProfile(@Req() req: AuthenticatedRequest) {
    const userId = req.user._id.toString();
    const profile = await this.healthProfileService.getProfile(userId);

    if (!profile) {
      return { success: false, message: 'Health profile not found' };
    }

    return { success: true, data: profile };
  }

  private mapFitnessGoal(fitnessGoal?: string): string | undefined {
    switch (fitnessGoal) {
      case 'lose_weight':
        return 'lose';
      case 'gain_muscle':
      case 'bulk':
        return 'gain';
      case 'maintain':
        return 'maintain';
      default:
        return undefined;
    }
  }
}
