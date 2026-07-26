import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, QueryFilter, Types, UpdateQuery } from 'mongoose';
import { Workout, WorkoutDocument } from './schemas/workout.schema';
import { UpdateWorkoutDto } from './dto/update-workout.dto';

export type WorkoutInput = Partial<Workout> & {
  exerciseName?: string;
  userId?: Types.ObjectId;
};

@Injectable()
export class WorkoutsService {
  constructor(
    @InjectModel(Workout.name) private workoutModel: Model<WorkoutDocument>,
  ) {}

  // --- EXISTING USER METHODS ---
  async create(dto: WorkoutInput) {
    // ✅ THE FIX: Reconstruct 'name' and 'category'.
    // Fallback 'category' is now 'Other' to match your Mongoose enum!
    const workoutData: Partial<Workout> = {
      ...dto,
      name: dto.name || dto.exerciseName || 'Unknown Workout',
      category: dto.category || 'Other',
    };

    return this.workoutModel.create(workoutData);
  }

  async findAll(userId: string) {
    return this.workoutModel.find({ userId }).sort({ date: -1 });
  }

  async findById(id: string) {
    const workout = await this.workoutModel.findById(id);
    if (!workout) throw new NotFoundException('Workout not found');
    return workout;
  }

  async update(id: string, dto: UpdateWorkoutDto) {
    const updated = await this.workoutModel.findByIdAndUpdate(id, dto, {
      returnDocument: 'after',
    });
    if (!updated) throw new NotFoundException('Workout not found');
    return updated;
  }

  async remove(id: string) {
    const deleted = await this.workoutModel.findByIdAndDelete(id);
    if (!deleted) throw new NotFoundException('Workout not found');
  }

  // --- ADMIN & CATALOG METHODS ---
  async findAllAdmin(search?: string, category?: string) {
    const query: QueryFilter<WorkoutDocument> = {
      isApproved: { $ne: false },
    };

    if (search) {
      query.name = { $regex: search, $options: 'i' };
    }
    if (category && category !== 'All') {
      query.category = category;
    }

    const workouts = await this.workoutModel
      .find(query)
      .sort({ createdAt: -1 });
    const totalItems = await this.workoutModel.countDocuments(query);

    return { success: true, workouts, totalItems };
  }

  async createAdminWorkout(dto: WorkoutInput) {
    const workoutData: Partial<Workout> = {
      ...dto,
      name: dto.name || dto.exerciseName || 'Unknown Workout',
      category: dto.category || 'Other', // ✅ Changed to 'Other'
    };
    const created = await this.workoutModel.create(workoutData);
    return { success: true, data: created };
  }

  async updateAdminWorkout(id: string, dto: UpdateQuery<WorkoutDocument>) {
    const updated = await this.workoutModel.findByIdAndUpdate(id, dto, {
      returnDocument: 'after',
    });
    if (!updated) throw new NotFoundException('Workout not found');
    return { success: true, data: updated };
  }

  async deleteAdminWorkout(id: string) {
    const deleted = await this.workoutModel.findByIdAndDelete(id);
    if (!deleted) throw new NotFoundException('Workout not found');
    return { success: true, message: 'Workout deleted' };
  }

  // ✅ IMAGE HANDLING METHODS
  async updateThumbnail(id: string, thumbnailPath: string) {
    const workout = await this.workoutModel.findById(id);
    if (!workout) throw new NotFoundException('Workout not found');

    workout.thumbnail = thumbnailPath;
    await workout.save();

    return { success: true, data: workout };
  }

  async addImages(id: string, imagePaths: string[]) {
    const workout = await this.workoutModel.findById(id);
    if (!workout) throw new NotFoundException('Workout not found');

    const existingImages = workout.images || [];
    workout.images = [...existingImages, ...imagePaths];
    await workout.save();

    return { success: true, data: workout };
  }
}
