import { Injectable } from '@nestjs/common';
import { Types } from 'mongoose';
import { HealthProfileRepository } from './healthProfile.repository';

@Injectable()
export class HealthProfileService {
  constructor(private readonly repo: HealthProfileRepository) {}

  private calculateBMI(weight: number, height: number): number {
    const heightInMeters = height / 100;
    return parseFloat((weight / (heightInMeters * heightInMeters)).toFixed(1));
  }

  private calculateBMR(
    weight: number,
    height: number,
    age: number,
    gender: string,
  ): number {
    let bmr = 10 * weight + 6.25 * height - 5 * age;
    if (gender.toLowerCase() === 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    return Math.round(bmr);
  }

  private getActivityMultiplier(level: string): number {
    const multipliers: Record<string, number> = {
      sedentary: 1.2,
      light: 1.375,
      moderate: 1.55,
      active: 1.725,
      very_active: 1.9,
    };
    return multipliers[level] || 1.55;
  }

  private calculateTDEE(bmr: number, activityLevel: string): number {
    return Math.round(bmr * this.getActivityMultiplier(activityLevel));
  }

  private calculateCalorieTarget(tdee: number, goal: string): number {
    switch (goal) {
      case 'lose':
        return tdee - 500;
      case 'gain':
        return tdee + 400;
      case 'maintain':
      default:
        return tdee;
    }
  }

  private calculateMacros(
    calorieTarget: number,
    goal: string,
  ): { protein: number; carbs: number; fats: number } {
    let proteinPercent = 0.3;
    let carbsPercent = 0.4;
    let fatsPercent = 0.3;

    if (goal === 'lose') {
      proteinPercent = 0.4;
      carbsPercent = 0.3;
      fatsPercent = 0.3;
    } else if (goal === 'gain') {
      proteinPercent = 0.3;
      carbsPercent = 0.45;
      fatsPercent = 0.25;
    }

    return {
      protein: Math.round((calorieTarget * proteinPercent) / 4),
      carbs: Math.round((calorieTarget * carbsPercent) / 4),
      fats: Math.round((calorieTarget * fatsPercent) / 9),
    };
  }

  async calculateAndUpdateProfile(
    userId: string,
    profileData: {
      weight: number;
      height: number;
      age: number;
      gender: string;
      activityLevel: string;
      goal: string;
    },
  ) {
    const { weight, height, age, gender, activityLevel, goal } = profileData;

    const bmi = this.calculateBMI(weight, height);
    const bmr = this.calculateBMR(weight, height, age, gender);
    const tdee = this.calculateTDEE(bmr, activityLevel);
    const targetCalories = this.calculateCalorieTarget(tdee, goal);
    const macros = this.calculateMacros(targetCalories, goal);

    const profile = {
      userId: new Types.ObjectId(userId),
      weight,
      height,
      age,
      gender,
      activityLevel,
      goal,
      bmi,
      bmr,
      tdee,
      targetCalories,
      macros,
    };

    return await this.repo.createOrUpdate(profile);
  }

  async getProfile(userId: string) {
    return await this.repo.getByUserId(userId);
  }
}
