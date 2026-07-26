import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  Query,
} from '@nestjs/common';
import { MealsService } from './meals.service';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { AdminGuard } from '../common/guards/admin.guard'; // ✅ Added AdminGuard
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ParseObjectIdPipe } from '../common/pipes/parse-object-id.pipe';
import type { UserDocument } from '../users/schemas/user.schema';

@Controller('meals')
@UseGuards(JwtAuthGuard)
export class MealsController {
  constructor(private readonly mealsService: MealsService) {}

  // USER ENDPOINTS (Keep existing functionality)

  @Post()
  async create(@CurrentUser() user: UserDocument, @Body() dto: CreateMealDto) {
    // Attach userId so it saves to the correct user's log
    return {
      success: true,
      data: await this.mealsService.create({ ...dto, userId: user._id }),
    };
  }

  @Get()
  async findAll(
    @CurrentUser() user: UserDocument,
    @Query('userId') userId?: string,
  ) {
    return {
      success: true,
      data: await this.mealsService.findAll(userId || user._id.toString()),
    };
  }

  @Get('admin/all')
  @UseGuards(AdminGuard)
  async findAllAdmin(
    @Query('search') search?: string,
    @Query('category') category?: string,
  ) {
    return this.mealsService.findAllAdmin(search, category);
  }

  @Get('admin/stats')
  @UseGuards(AdminGuard)
  async getAdminStats() {
    return this.mealsService.getAdminStats();
  }

  @Get(':id')
  async findOne(@Param('id', ParseObjectIdPipe) id: string) {
    return { success: true, data: await this.mealsService.findById(id) };
  }

  @Put(':id')
  async update(
    @Param('id', ParseObjectIdPipe) id: string,
    @Body() dto: UpdateMealDto,
  ) {
    return { success: true, data: await this.mealsService.update(id, dto) };
  }

  @Delete(':id')
  async remove(@Param('id', ParseObjectIdPipe) id: string) {
    return { success: true, data: await this.mealsService.remove(id) };
  }
}
