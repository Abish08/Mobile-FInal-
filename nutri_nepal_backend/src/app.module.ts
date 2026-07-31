import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { ThrottlerModule } from '@nestjs/throttler';
import { ServeStaticModule } from '@nestjs/serve-static';
import { MulterModule } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { join } from 'path';

import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { MealsModule } from './meals/meals.module';
import { WorkoutsModule } from './workouts/workouts.module';
import { ProgressModule } from './progress/progress.module';
import { UploadController } from './upload/upload.controller';
import { FoodsModule } from './foods/foods.module';
import { FoodLogsModule } from './foods/foodLogs.module';
import { WorkoutLogsModule } from './workouts/workoutLogs.module';
import { HealthProfileModule } from './healthprofile/healthProfile.module';
import { AiModule } from './ai/ai.module';

@Module({
  imports: [
    ConfigModule.forRoot({ envFilePath: './config.env', isGlobal: true }),

    ServeStaticModule.forRoot({
      rootPath: join(process.cwd(), 'uploads'),
      serveRoot: '/uploads',
    }),

    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({
        uri: config.get('LOCAL_DATABASE_URI'),
      }),
      inject: [ConfigService],
    }),

    ThrottlerModule.forRoot([{ name: 'default', ttl: 60000, limit: 100 }]),

    MulterModule.register({
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, callback) => {
          const uniqueSuffix =
            Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          callback(null, `${uniqueSuffix}${ext}`);
        },
      }),
    }),

    UsersModule,
    AuthModule,
    MealsModule,
    WorkoutsModule,
    ProgressModule,
    FoodsModule,

    // ✅ ADD THESE THREE TO THE IMPORTS ARRAY
    FoodLogsModule,
    WorkoutLogsModule,
    HealthProfileModule,
    AiModule,
  ],
  controllers: [UploadController],
})
export class AppModule {}
