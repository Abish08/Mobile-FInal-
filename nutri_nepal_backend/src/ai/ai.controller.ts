import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { UserDocument } from '../users/schemas/user.schema';
import { AiService } from './ai.service';
import { AiChatDto } from './dto/chat.dto';

@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('chat')
  async chat(@Body() dto: AiChatDto, @CurrentUser() user: UserDocument) {
    return {
      success: true,
      data: await this.aiService.chat(dto.message, user, dto.history ?? []),
    };
  }
}
