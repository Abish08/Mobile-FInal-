import {
  Injectable,
  NotFoundException,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, QueryFilter, SortOrder, UpdateQuery } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { UpdateHealthProfileDto } from './dto/update-health-profile.dto';

type PublicUser = Omit<User, 'password'> & {
  _id?: unknown;
};

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async register(dto: CreateUserDto) {
    const exists = await this.userModel.findOne({ email: dto.email });
    if (exists) throw new BadRequestException('Email already exists');
    const user = await this.userModel.create(dto);
    const res = user.toObject() as PublicUser & { password?: string };
    delete res.password;
    return res;
  }

  async login(dto: LoginUserDto) {
    const user = await this.userModel
      .findOne({ email: dto.email })
      .select('+password');
    if (!user || !(await user.matchPassword(dto.password)))
      throw new UnauthorizedException('Invalid credentials');
    const token = user.getSignedJwtToken();
    const res = user.toObject() as PublicUser & { password?: string };
    delete res.password;
    return { success: true, token, data: res };
  }

  async findById(id: string) {
    const user = await this.userModel.findById(id);
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async updateProfile(userId: string, dto: UpdateHealthProfileDto) {
    const updatedUser = await this.userModel.findByIdAndUpdate(
      userId,
      { $set: dto },
      { returnDocument: 'after', runValidators: true },
    );
    if (!updatedUser) throw new NotFoundException('User not found');
    return updatedUser;
  }

  // ==========================================
  // ✅ NEW: ADMIN USER MANAGEMENT METHODS
  // ==========================================

  async findAll(search?: string, goal?: string, sortBy: string = 'createdAt') {
    const query: QueryFilter<UserDocument> = {};

    if (search) {
      query.$or = [
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    if (goal && goal !== 'all') {
      query.fitnessGoal = goal;
    }

    let sortOption: Record<string, SortOrder> = {};
    if (sortBy === 'newest') sortOption = { createdAt: -1 };
    else if (sortBy === 'oldest') sortOption = { createdAt: 1 };
    else if (sortBy === 'name') sortOption = { firstName: 1 };
    else sortOption = { createdAt: -1 };

    const users = await this.userModel
      .find(query)
      .select('-password')
      .sort(sortOption);

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const newToday = await this.userModel.countDocuments({
      createdAt: { $gte: today },
    });

    return {
      success: true,
      users,
      totalUsers: users.length,
      newToday,
    };
  }

  async getAdminStats() {
    const totalUsers = await this.userModel.countDocuments();

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const newToday = await this.userModel.countDocuments({
      createdAt: { $gte: today },
    });

    const usersByGoal = await this.userModel.aggregate([
      { $group: { _id: '$fitnessGoal', count: { $sum: 1 } } },
    ]);

    const bmiDistribution = await this.userModel.aggregate([
      {
        $match: {
          height: { $exists: true, $ne: null },
          weight: { $exists: true, $ne: null },
        },
      },
      {
        $addFields: {
          bmi: {
            $divide: [
              '$weight',
              {
                $multiply: [
                  { $divide: ['$height', 100] },
                  { $divide: ['$height', 100] },
                ],
              },
            ],
          },
        },
      },
      {
        $addFields: {
          bmiCategory: {
            $cond: {
              if: { $lt: ['$bmi', 18.5] },
              then: 'Underweight',
              else: {
                $cond: {
                  if: { $lt: ['$bmi', 25] },
                  then: 'Normal',
                  else: {
                    $cond: {
                      if: { $lt: ['$bmi', 30] },
                      then: 'Overweight',
                      else: 'Obese',
                    },
                  },
                },
              },
            },
          },
        },
      },
      { $group: { _id: '$bmiCategory', count: { $sum: 1 } } },
    ]);

    return {
      success: true,
      stats: { totalUsers, newToday, usersByGoal, bmiDistribution },
    };
  }

  async updateUser(userId: string, updateData: UpdateQuery<UserDocument>) {
    const updatedUser = await this.userModel
      .findByIdAndUpdate(
        userId,
        { $set: updateData },
        { returnDocument: 'after', runValidators: true },
      )
      .select('-password');

    if (!updatedUser) throw new NotFoundException('User not found');
    return { success: true, user: updatedUser };
  }

  async deleteUser(userId: string) {
    const deletedUser = await this.userModel.findByIdAndDelete(userId);
    if (!deletedUser) throw new NotFoundException('User not found');
    return { success: true, message: 'User deleted successfully' };
  }
}
