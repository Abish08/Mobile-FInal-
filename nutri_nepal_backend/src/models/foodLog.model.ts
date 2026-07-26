import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type FoodLogDocument = FoodLog & Document;

@Schema({ timestamps: true })
export class FoodLog {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId!: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Food', required: true })
  foodId!: Types.ObjectId;

  @Prop({ required: true, min: 0.1, default: 1 })
  servings!: number;

  @Prop({ required: true, enum: ['Breakfast', 'Lunch', 'Dinner', 'Snack'] })
  mealType!: string;

  @Prop({ required: true, default: Date.now })
  date!: Date;

  @Prop({ required: true })
  totalCalories!: number;

  @Prop({ required: true })
  totalProtein!: number;

  @Prop({ required: true })
  totalCarbs!: number;

  @Prop({ required: true })
  totalFats!: number;
}

export const FoodLogSchema = SchemaFactory.createForClass(FoodLog);
FoodLogSchema.index({ userId: 1, date: 1 });
