import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  HealthProfile,
  HealthProfileDocument,
} from './schemas/healthProfile.schema';

export type HealthProfileData = Omit<HealthProfile, 'userId'> & {
  userId: Types.ObjectId;
};

@Injectable()
export class HealthProfileRepository {
  constructor(
    @InjectModel(HealthProfile.name)
    private readonly healthProfileModel: Model<HealthProfileDocument>,
  ) {}

  async createOrUpdate(
    data: HealthProfileData,
  ): Promise<HealthProfileDocument> {
    return await this.healthProfileModel.findOneAndUpdate(
      { userId: data.userId },
      data,
      { returnDocument: 'after', upsert: true },
    );
  }

  async getByUserId(userId: string): Promise<HealthProfileDocument | null> {
    return await this.healthProfileModel.findOne({
      userId: new Types.ObjectId(userId),
    });
  }
}
