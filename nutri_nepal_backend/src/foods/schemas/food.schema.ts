import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type FoodDocument = Food & Document;

@Schema({ 
  collection: 'foods',
  timestamps: true 
})
export class Food {
  @Prop({ required: true })
  name!: string;

  @Prop({ required: true })
  category!: string;

  @Prop({ required: true })
  servingSize!: number;

  @Prop({ required: true })
  calories!: number;

  @Prop({ required: true })
  protein!: number;

  @Prop({ required: true })
  carbs!: number;

  @Prop({ required: true })
  fats!: number;

  @Prop()
  fiber?: number;

  @Prop()
  sugar?: number;

  @Prop()
  sodium?: number;

  @Prop()
  description?: string;

  @Prop({ default: true })
  isApproved!: boolean;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  createdBy?: Types.ObjectId;

  @Prop([String])
  images?: string[];

  @Prop()
  thumbnail?: string;
}

export const FoodSchema = SchemaFactory.createForClass(Food);