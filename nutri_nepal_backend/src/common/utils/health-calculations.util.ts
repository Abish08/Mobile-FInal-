import { BadRequestException } from '@nestjs/common';

export type HealthGender = 'male' | 'female' | 'other';
export type ActivityLevel =
  | 'sedentary'
  | 'light'
  | 'moderate'
  | 'active'
  | 'very_active';
export type HealthGoal = 'lose' | 'maintain' | 'gain';
export type BmiCategory = 'Underweight' | 'Normal' | 'Overweight' | 'Obese';

export type HealthCalculationInput = {
  weightKg: number;
  heightCm: number;
  age: number;
  gender: string;
  activityLevel: string;
  goal: string;
};

export type HealthTargets = {
  weight: number;
  height: number;
  age: number;
  gender: HealthGender;
  activityLevel: ActivityLevel;
  goal: HealthGoal;
  bmi: number;
  bmiCategory: BmiCategory;
  bmr: number;
  tdee: number;
  targetCalories: number;
  macros: {
    protein: number;
    carbs: number;
    fats: number;
  };
};

export const ACTIVITY_MULTIPLIERS: Record<ActivityLevel, number> = {
  sedentary: 1.2,
  light: 1.375,
  moderate: 1.55,
  active: 1.725,
  very_active: 1.9,
};

export const GOAL_CALORIE_ADJUSTMENTS: Record<HealthGoal, number> = {
  lose: -500,
  maintain: 0,
  gain: 400,
};

const MACRO_RATIOS = {
  protein: 0.3,
  carbs: 0.45,
  fats: 0.25,
} as const;

const GOAL_ALIASES: Record<string, HealthGoal> = {
  lose: 'lose',
  weight_loss: 'lose',
  lose_weight: 'lose',
  maintain: 'maintain',
  maintenance: 'maintain',
  gain: 'gain',
  muscle_gain: 'gain',
  gain_muscle: 'gain',
  bulk: 'gain',
};

export function normalizeGender(value: string): HealthGender {
  const normalized = value?.trim().toLowerCase();
  if (
    normalized === 'male' ||
    normalized === 'female' ||
    normalized === 'other'
  ) {
    return normalized;
  }
  throw new BadRequestException(`Unsupported gender: ${value}`);
}

export function normalizeActivityLevel(value: string): ActivityLevel {
  const normalized = value?.trim().toLowerCase() as ActivityLevel;
  if (Object.prototype.hasOwnProperty.call(ACTIVITY_MULTIPLIERS, normalized)) {
    return normalized;
  }
  throw new BadRequestException(`Unsupported activity level: ${value}`);
}

export function normalizeGoal(value: string): HealthGoal {
  const normalized = value?.trim().toLowerCase();
  const goal = GOAL_ALIASES[normalized];
  if (goal) return goal;
  throw new BadRequestException(`Unsupported goal: ${value}`);
}

export function calculateBMI(weightKg: number, heightCm: number): number {
  assertPositiveFinite(weightKg, 'weight');
  assertPositiveFinite(heightCm, 'height');
  const heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

export function getBMICategory(bmi: number): BmiCategory {
  assertPositiveFinite(bmi, 'bmi');
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}

export function calculateBMR(input: {
  weightKg: number;
  heightCm: number;
  age: number;
  gender: string;
}): number {
  const weightKg = assertPositiveFinite(input.weightKg, 'weight');
  const heightCm = assertPositiveFinite(input.heightCm, 'height');
  const age = assertPositiveFinite(input.age, 'age');
  const gender = normalizeGender(input.gender);
  const genderOffset = gender === 'male' ? 5 : -161;
  return 10 * weightKg + 6.25 * heightCm - 5 * age + genderOffset;
}

export function calculateTDEE(bmr: number, activityLevel: string): number {
  assertPositiveFinite(bmr, 'bmr');
  return bmr * ACTIVITY_MULTIPLIERS[normalizeActivityLevel(activityLevel)];
}

export function calculateGoalCalories(tdee: number, goal: string): number {
  assertPositiveFinite(tdee, 'tdee');
  return Math.round(tdee + GOAL_CALORIE_ADJUSTMENTS[normalizeGoal(goal)]);
}

export function calculateMacros(
  calorieTarget: number,
): HealthTargets['macros'] {
  assertPositiveFinite(calorieTarget, 'calorie target');
  return {
    protein: Math.round((calorieTarget * MACRO_RATIOS.protein) / 4),
    carbs: Math.round((calorieTarget * MACRO_RATIOS.carbs) / 4),
    fats: Math.round((calorieTarget * MACRO_RATIOS.fats) / 9),
  };
}

export function calculateHealthTargets(
  input: HealthCalculationInput,
): HealthTargets {
  const weight = assertPositiveFinite(input.weightKg, 'weight');
  const height = assertPositiveFinite(input.heightCm, 'height');
  const age = assertPositiveFinite(input.age, 'age');
  const gender = normalizeGender(input.gender);
  const activityLevel = normalizeActivityLevel(input.activityLevel);
  const goal = normalizeGoal(input.goal);

  const rawBmi = calculateBMI(weight, height);
  const bmr = calculateBMR({ weightKg: weight, heightCm: height, age, gender });
  const tdee = calculateTDEE(bmr, activityLevel);
  const targetCalories = calculateGoalCalories(tdee, goal);

  return {
    weight,
    height,
    age,
    gender,
    activityLevel,
    goal,
    bmi: roundTo(rawBmi, 1),
    bmiCategory: getBMICategory(rawBmi),
    bmr,
    tdee,
    targetCalories,
    macros: calculateMacros(targetCalories),
  };
}

function assertPositiveFinite(value: number, field: string): number {
  const numeric = Number(value);
  if (!Number.isFinite(numeric) || numeric <= 0) {
    throw new BadRequestException(`${field} must be a positive finite number`);
  }
  return numeric;
}

function roundTo(value: number, decimals: number): number {
  const factor = 10 ** decimals;
  return Math.round(value * factor) / factor;
}
