import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);
  
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  
  // Enable CORS
  app.enableCors({
    origin: true,
    credentials: true,
  });

  const port = config.get('PORT', 3000);
  
  // Listen on ALL network interfaces (0.0.0.0) so my phone can connect
  await app.listen(port, '0.0.0.0');
  
  console.log(` NutriNepal Backend running on http://localhost:${port}/api/v1`);
  // Fixed: Changed hardcoded .5 to your actual ipconfig IP (.2)
  console.log(`📱 Network access: http://192.168.101.2:${port}/api/v1`);
}

bootstrap();