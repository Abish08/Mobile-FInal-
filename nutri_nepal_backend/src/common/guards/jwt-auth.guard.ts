import { Injectable, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) { 
    super(); 
  }

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    // Check for public routes - look at both handler and class
    const isPublic = this.reflector.getAllAndOverride<boolean>('isPublic', [
      ctx.getHandler(),
      ctx.getClass(),
    ]);

    // If route is marked public, allow access without authentication
    if (isPublic) {
      return true;
    }

    // Otherwise, proceed with JWT authentication
    const canActivate = await super.canActivate(ctx);
    return canActivate as boolean;
  }

  handleRequest(err: any, user: any) {
    if (err || !user) {
      throw err || new UnauthorizedException('Not authorized');
    }
    return user;
  }
}