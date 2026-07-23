import { Controller, Post, UploadedFile, UseInterceptors, Get, Param, Res } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { join } from 'path';
import { existsSync } from 'fs';

@Controller('upload')
export class UploadController {  // ✅ Make sure 'export' is here!
  @Post('profile')
  @UseInterceptors(FileInterceptor('image'))
  uploadProfilePicture(@UploadedFile() file: Express.Multer.File) {
    return {
      success: true,
      message: 'Profile picture uploaded successfully',
      imageUrl: `http://192.168.101.6:3000/uploads/${file.filename}`,
      filename: file.filename,
    };
  }

  @Post('meal')
  @UseInterceptors(FileInterceptor('image'))
  uploadMealPicture(@UploadedFile() file: Express.Multer.File) {
    return {
      success: true,
      message: 'Meal picture uploaded successfully',
      imageUrl: `http://192.168.101.6:3000/uploads/${file.filename}`,
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