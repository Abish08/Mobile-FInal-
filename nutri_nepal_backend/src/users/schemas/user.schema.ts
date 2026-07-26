import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import type { Secret, SignOptions } from 'jsonwebtoken';
import type { StringValue } from 'ms';

export type UserDocument = User &
  HydratedDocument<User> & {
    getSignedJwtToken(): string;
    matchPassword(enteredPassword: string): Promise<boolean>;
  };

@Schema({ timestamps: true })
export class User {
  // --- Existing Auth Fields ---
  @Prop({ required: true, trim: true }) firstName!: string;
  @Prop({ required: true, trim: true }) lastName!: string;
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email!: string;
  @Prop({ required: true, trim: true }) phone!: string;
  @Prop({ required: true, minlength: 6, select: false }) password!: string;
  @Prop({ default: 'default-profile.png' }) profilePicture!: string;
  @Prop({ default: 'user' }) role!: string;

  // --- NEW: Health Profile Fields (Week 4) ---
  @Prop({ type: Number }) age?: number;
  @Prop({ type: Number }) weight?: number; // in kg
  @Prop({ type: Number }) height?: number; // in cm
  @Prop({ type: String, enum: ['male', 'female', 'other'] }) gender?: string;
  @Prop({
    type: String,
    enum: ['lose_weight', 'maintain', 'gain_muscle', 'bulk'],
  })
  fitnessGoal?: string;
  @Prop({ type: [String] }) healthConditions?: string[]; // e.g., ['Diabetes', 'Hypertension']
}

export const UserSchema = SchemaFactory.createForClass(User);

UserSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

UserSchema.methods.getSignedJwtToken = function (
  this: UserDocument & { _id: Types.ObjectId },
): string {
  const secret = process.env.JWT_SECRET as Secret;
  const options: SignOptions = {
    expiresIn: (process.env.JWT_EXPIRE || '7d') as StringValue,
  };
  return jwt.sign({ id: this._id.toString() }, secret, options);
};

UserSchema.methods.matchPassword = async function (
  this: UserDocument,
  entered: string,
): Promise<boolean> {
  return bcrypt.compare(entered, this.password);
};
