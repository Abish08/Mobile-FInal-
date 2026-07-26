import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type HealthProfileDocument = HealthProfile & Document;

@Schema({ timestamps: true })
export class HealthProfile {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, unique: true })
  userId!: Types.ObjectId; // ✅ Added ! here

  @Prop({ required: true })
  weight!: number;

  @Prop({ required: true })
  height!: number;

  @Prop({ required: true })
  age!: number;

  @Prop({ required: true, enum: ['male', 'female', 'other'] })
  gender!: string;

  @Prop({
    required: true,
    enum: ['sedentary', 'light', 'moderate', 'active', 'very_active'],
  })
  activityLevel!: string;

  @Prop({ required: true, enum: ['lose', 'maintain', 'gain'] })
  goal!: string;

  @Prop({ required: true })
  bmi!: number;

  @Prop({ required: true })
  bmr!: number;

  @Prop({ required: true })
  tdee!: number;

  @Prop({ required: true })
  targetCalories!: number;

  @Prop({
    type: {
      protein: { type: Number, required: true },
      carbs: { type: Number, required: true },
      fats: { type: Number, required: true },
    },
    required: true,
  })
  macros!: {
    protein: number;
    carbs: number;
    fats: number;
  };
}

export const HealthProfileSchema = SchemaFactory.createForClass(HealthProfile);
