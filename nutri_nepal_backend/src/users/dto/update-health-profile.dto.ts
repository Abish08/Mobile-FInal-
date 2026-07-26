import { IsNumber, IsString, IsOptional, IsArray, IsIn } from 'class-validator';

export class UpdateHealthProfileDto {
  @IsOptional() @IsNumber() age?: number;
  @IsOptional() @IsNumber() weight?: number;
  @IsOptional() @IsNumber() height?: number;

  @IsOptional() @IsString() @IsIn(['male', 'female', 'other']) gender?: string;
  @IsOptional()
  @IsString()
  @IsIn(['lose_weight', 'maintain', 'gain_muscle', 'bulk'])
  fitnessGoal?: string;
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  healthConditions?: string[];

  //  Allow updating the profile picture URL
  @IsOptional() @IsString() profilePicture?: string;
}
