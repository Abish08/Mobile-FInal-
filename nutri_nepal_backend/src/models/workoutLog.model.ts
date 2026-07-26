import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type WorkoutLogDocument = WorkoutLog & Document;

@Schema({ timestamps: true })
export class WorkoutLog {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId!: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Workout', required: true })
  workoutId!: Types.ObjectId;

  @Prop({ required: true, min: 1 })
  duration!: number;

  @Prop({ required: true, min: 0 })
  caloriesBurned!: number;

  @Prop({ required: true, default: Date.now })
  date!: Date;
}

export const WorkoutLogSchema = SchemaFactory.createForClass(WorkoutLog);
WorkoutLogSchema.index({ userId: 1, date: 1 });
