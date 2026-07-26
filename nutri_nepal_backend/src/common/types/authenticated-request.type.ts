import type { Request } from 'express';
import type { UserDocument } from '../../users/schemas/user.schema';

export type AuthenticatedRequest = Request & {
  user: UserDocument;
};
