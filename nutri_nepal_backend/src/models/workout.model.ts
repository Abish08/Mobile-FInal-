import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type WorkoutDocument = Workout & Document;

@Schema({ timestamps: true })
export class Workout {
  @Prop({ required: true, trim: true })
  name!: string;

  @Prop({
    required: true,
    enum: [
      'Cardio',
      'Strength',
      'Flexibility',
      'Yoga',
      'HIIT',
      'Sports',
      'Other',
    ],
  })
  category!: string;

  @Prop({ required: true, min: 1 })
  duration!: number;

  @Prop({ required: true, min: 0 })
  caloriesBurned!: number;

  @Prop({ required: true, enum: ['Beginner', 'Intermediate', 'Advanced'] })
  difficulty!: string;

  @Prop({ trim: true })
  description?: string;

  @Prop({ trim: true })
  equipment?: string;

  @Prop([
    {
      type: { type: String, enum: ['image', 'video'], required: true },
      url: String,
      publicId: String,
      thumbnail: String,
    },
  ])
  media?: Array<{
    type: string;
    url: string;
    publicId: string;
    thumbnail?: string;
  }>;

  @Prop({ default: true })
  isApproved!: boolean;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  createdBy?: Types.ObjectId;
}

export const WorkoutSchema = SchemaFactory.createForClass(Workout);
WorkoutSchema.index({ name: 'text', category: 1 });
