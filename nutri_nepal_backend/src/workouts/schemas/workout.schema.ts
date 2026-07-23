import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type WorkoutDocument = Workout & Document;

@Schema({ collection: 'workouts', timestamps: true })
export class Workout {
  @Prop({ required: true })
  name!: string;

  @Prop({ required: true, enum: ['Strength', 'Cardio', 'Flexibility', 'Other'] })
  category!: string;

  @Prop()
  duration?: number; // in minutes

  @Prop()
  caloriesBurned?: number;

  @Prop({ enum: ['Beginner', 'Intermediate', 'Advanced'] })
  difficulty?: string;

  @Prop()
  description?: string;

  @Prop()
  equipment?: string;

  @Prop({ default: true })
  isApproved!: boolean;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  createdBy?: Types.ObjectId;

  // ✅ NEW: Image and YouTube fields
  @Prop()
  thumbnail?: string;

  @Prop([String])
  images?: string[];

  @Prop()
  youtubeUrl?: string;

  // Figma fields (optional, for future use)
  @Prop() sets?: number;
  @Prop() reps?: number;
  @Prop() rest?: string;
  @Prop() intensity?: string;
  @Prop() cycles?: number;
  @Prop() focus?: string;
  @Prop() day?: string;
}

export const WorkoutSchema = SchemaFactory.createForClass(Workout);