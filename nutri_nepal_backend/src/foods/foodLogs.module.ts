import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { FoodLog, FoodLogSchema } from '../models/foodLog.model';
import { Food, FoodSchema } from './schemas/food.schema';
import { FoodLogController } from '../controllers/foodLog.controller';
import { FoodLogService } from '../services/foodLog.service';
import { FoodLogRepository } from '../repositories/foodLog.repository';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: FoodLog.name, schema: FoodLogSchema },
      { name: Food.name, schema: FoodSchema }, // ✅ Register Food model here too
    ]),
  ],
  controllers: [FoodLogController],
  providers: [FoodLogService, FoodLogRepository],
  exports: [FoodLogService],
})
export class FoodLogsModule {}
