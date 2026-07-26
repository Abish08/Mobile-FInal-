import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type FoodDocument = Food & Document;

@Schema({ timestamps: true })
export class Food {
  @Prop({ required: true, trim: true })
  name!: string;

  @Prop({
    required: true,
    enum: [
      'Breakfast',
      'Lunch',
      'Dinner',
      'Snacks',
      'Beverages',
      'Fruits',
      'Vegetables',
      'Grains',
      'Protein',
      'Dairy',
    ],
  })
  category!: string;

  @Prop({ required: true, min: 0 })
  servingSize!: number;

  @Prop({ required: true, min: 0 })
  calories!: number;

  @Prop({ required: true, min: 0 })
  protein!: number;

  @Prop({ required: true, min: 0 })
  carbs!: number;

  @Prop({ required: true, min: 0 })
  fats!: number;

  @Prop({ default: 0, min: 0 })
  fiber?: number;

  @Prop({ default: 0, min: 0 })
  sugar?: number;

  @Prop({ default: 0, min: 0 })
  sodium?: number;

  @Prop({ trim: true })
  description?: string;

  @Prop({
    type: {
      ingredients: [{ type: String }],
      instructions: [{ type: String }],
      prepTime: { type: Number, default: 0 },
      cookTime: { type: Number, default: 0 },
      servings: { type: Number, default: 1 },
      difficulty: {
        type: String,
        enum: ['Easy', 'Medium', 'Hard'],
        default: 'Medium',
      },
    },
  })
  recipe?: {
    ingredients: string[];
    instructions: string[];
    prepTime: number;
    cookTime: number;
    servings: number;
    difficulty: string;
  };

  @Prop([{ url: String, publicId: String }])
  images?: Array<{ url: string; publicId: string }>;

  @Prop({ type: { url: String, publicId: String } })
  thumbnail?: { url: string; publicId: string };

  @Prop({ default: true })
  isApproved!: boolean;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  createdBy?: Types.ObjectId;
}

export const FoodSchema = SchemaFactory.createForClass(Food);
FoodSchema.index({ name: 'text', category: 1 });
