import {
  IsArray,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class AiChatMessageDto {
  @IsIn(['user', 'model'])
  role!: 'user' | 'model';

  @IsString()
  @IsNotEmpty()
  @MaxLength(1600)
  text!: string;
}

export class AiChatDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(1200)
  message!: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AiChatMessageDto)
  history?: AiChatMessageDto[];
}
