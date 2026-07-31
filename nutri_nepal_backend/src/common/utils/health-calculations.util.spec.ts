import { BadRequestException } from '@nestjs/common';
import {
  ACTIVITY_MULTIPLIERS,
  calculateBMI,
  calculateBMR,
  calculateGoalCalories,
  calculateHealthTargets,
  calculateMacros,
  calculateTDEE,
  getBMICategory,
  normalizeGoal,
} from './health-calculations.util';

describe('health calculations', () => {
  const baseline = {
    age: 23,
    weightKg: 77,
    heightCm: 182,
    gender: 'male',
    activityLevel: 'moderate',
  };

  it('calculates maintain targets from the shared formula', () => {
    const targets = calculateHealthTargets({ ...baseline, goal: 'maintain' });

    expect(calculateBMI(77, 182)).toBeCloseTo(23.25, 2);
    expect(targets.bmi).toBe(23.2);
    expect(targets.bmiCategory).toBe('Normal');
    expect(targets.bmr).toBeCloseTo(1797.5);
    expect(targets.tdee).toBeCloseTo(2786.125);
    expect(targets.targetCalories).toBe(2786);
    expect(targets.macros).toEqual({ protein: 209, carbs: 313, fats: 77 });
  });

  it('calculates lose and gain calorie targets and macros', () => {
    expect(calculateHealthTargets({ ...baseline, goal: 'lose' })).toMatchObject(
      {
        targetCalories: 2286,
        macros: { protein: 171, carbs: 257, fats: 64 },
      },
    );

    expect(calculateHealthTargets({ ...baseline, goal: 'gain' })).toMatchObject(
      {
        targetCalories: 3186,
        macros: { protein: 239, carbs: 358, fats: 89 },
      },
    );
  });

  it('supports existing goal aliases', () => {
    expect(normalizeGoal('weight_loss')).toBe('lose');
    expect(normalizeGoal('lose_weight')).toBe('lose');
    expect(normalizeGoal('maintenance')).toBe('maintain');
    expect(normalizeGoal('muscle_gain')).toBe('gain');
    expect(normalizeGoal('gain_muscle')).toBe('gain');
    expect(normalizeGoal('bulk')).toBe('gain');
  });

  it('uses the female Mifflin-St Jeor offset', () => {
    expect(
      calculateBMR({
        weightKg: 77,
        heightCm: 182,
        age: 23,
        gender: 'female',
      }),
    ).toBeCloseTo(1631.5);
  });

  it('supports every activity multiplier without fallback', () => {
    const bmr = 1800;
    for (const [level, multiplier] of Object.entries(ACTIVITY_MULTIPLIERS)) {
      expect(calculateTDEE(bmr, level)).toBeCloseTo(bmr * multiplier);
    }
  });

  it('classifies adult BMI boundaries consistently', () => {
    expect(getBMICategory(18.49)).toBe('Underweight');
    expect(getBMICategory(18.5)).toBe('Normal');
    expect(getBMICategory(24.99)).toBe('Normal');
    expect(getBMICategory(25)).toBe('Overweight');
    expect(getBMICategory(29.99)).toBe('Overweight');
    expect(getBMICategory(30)).toBe('Obese');
  });

  it('keeps macros consistent with the final calorie target', () => {
    const calories = calculateGoalCalories(2786.125, 'maintain');
    expect(calculateMacros(calories)).toEqual({
      protein: Math.round((calories * 0.3) / 4),
      carbs: Math.round((calories * 0.45) / 4),
      fats: Math.round((calories * 0.25) / 9),
    });
  });

  it('rejects invalid inputs instead of returning NaN or Infinity', () => {
    expect(() => calculateBMI(0, 182)).toThrow(BadRequestException);
    expect(() => calculateBMI(77, Number.NaN)).toThrow(BadRequestException);
    expect(() =>
      calculateHealthTargets({ ...baseline, goal: 'unknown' }),
    ).toThrow(BadRequestException);
    expect(() =>
      calculateHealthTargets({
        ...baseline,
        activityLevel: 'unknown',
        goal: 'maintain',
      }),
    ).toThrow(BadRequestException);
  });
});
