import { IsNumber, IsOptional, IsMongoId } from 'class-validator';

export class CreateProgressDto {
  @IsMongoId()
  @IsOptional()
  userId?: string;

  @IsNumber()
  weight!: number;

  @IsNumber()
  @IsOptional()
  bodyFat?: number;

  @IsNumber()
  @IsOptional()
  muscleMass?: number;
}
