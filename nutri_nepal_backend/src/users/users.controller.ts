import { Controller, Post, Get, Body, Param, UseGuards, Patch, Query, Delete } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { UpdateHealthProfileDto } from './dto/update-health-profile.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { AdminGuard } from '../common/guards/admin.guard'; 
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('register') @Public()
  async register(@Body() dto: CreateUserDto) {
    return { success: true, data: await this.usersService.register(dto) };
  }

  @Post('login') @Public()
  async login(@Body() dto: LoginUserDto) {
    return this.usersService.login(dto);
  }

  @Get('me') @UseGuards(JwtAuthGuard)
  async getMe(@CurrentUser() user: any) {
    return { success: true, data: await this.usersService.findById(user._id.toString()) };
  }

  @Get(':id') @UseGuards(JwtAuthGuard) // ✅ Changed from @Public() to @UseGuards(JwtAuthGuard) for security
  async findOne(@Param('id') id: string) {
    return { success: true, data: await this.usersService.findById(id) };
  }

  @Patch('profile') @UseGuards(JwtAuthGuard)
  async updateProfile(
    @CurrentUser() user: any,
    @Body() dto: UpdateHealthProfileDto
  ) {
    return { 
      success: true, 
      message: 'Profile updated successfully',
      data: await this.usersService.updateProfile(user._id.toString(), dto) 
    };
  }



  @Get()
  @UseGuards(JwtAuthGuard, AdminGuard)
  async getAllUsers(
    @Query('search') search?: string,
    @Query('goal') goal?: string,
    @Query('sortBy') sortBy?: string,
  ) {
    return this.usersService.findAll(search, goal, sortBy);
  }

  @Get('admin/stats')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async getAdminStats() {
    return this.usersService.getAdminStats();
  }

  @Patch('admin/:id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async updateUser(@Param('id') id: string, @Body() updateData: any) {
    return this.usersService.updateUser(id, updateData);
  }

  @Delete('admin/:id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  async deleteUser(@Param('id') id: string) {
    return this.usersService.deleteUser(id);
  }
}