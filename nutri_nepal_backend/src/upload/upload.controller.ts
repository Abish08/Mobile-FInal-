import {
  BadRequestException,
  Controller,
  Get,
  Param,
  Post,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { existsSync } from 'fs';
import { join } from 'path';
import { AdminGuard } from '../common/guards/admin.guard';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

const imageUploadOptions = {
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (
    req: unknown,
    file: Express.Multer.File,
    callback: (error: Error | null, acceptFile: boolean) => void,
  ) => {
    if (!file.mimetype.match(/^image\/(jpeg|jpg|png|gif|webp)$/)) {
      callback(new BadRequestException('Only image files are allowed!'), false);
      return;
    }
    callback(null, true);
  },
};

@Controller('upload')
export class UploadController {
  @Post('profile')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('image', imageUploadOptions))
  uploadProfilePicture(@UploadedFile() file: Express.Multer.File) {
    return {
      success: true,
      message: 'Profile picture uploaded successfully',
      imageUrl: `/uploads/${file.filename}`,
      filename: file.filename,
    };
  }

  @Post('meal')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @UseInterceptors(FileInterceptor('image', imageUploadOptions))
  uploadMealPicture(@UploadedFile() file: Express.Multer.File) {
    return {
      success: true,
      message: 'Meal picture uploaded successfully',
      imageUrl: `/uploads/${file.filename}`,
      filename: file.filename,
    };
  }

  @Get(':filename')
  serveImage(@Param('filename') filename: string, @Res() res: Response) {
    const filePath = join(__dirname, '../../uploads', filename);
    if (existsSync(filePath)) {
      res.sendFile(filePath);
    } else {
      res.status(404).json({ message: 'Image not found' });
    }
  }
}
