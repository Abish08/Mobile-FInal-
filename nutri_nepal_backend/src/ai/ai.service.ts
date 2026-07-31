import {
  HttpException,
  HttpStatus,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { UserDocument } from '../users/schemas/user.schema';
import type { AiChatMessageDto } from './dto/chat.dto';

type GeminiResponse = {
  candidates?: Array<{
    content?: {
      parts?: Array<{
        text?: string;
      }>;
    };
  }>;
  error?: { code?: number; message?: string; status?: string };
};

@Injectable()
export class AiService {
  constructor(private readonly config: ConfigService) {}

  async chat(
    message: string,
    user: UserDocument,
    history: AiChatMessageDto[] = [],
  ) {
    const apiKey = this.config.get<string>('GEMINI_API_KEY');
    if (!apiKey) {
      return {
        reply:
          'AI is not configured yet. Add GEMINI_API_KEY to config.env on the backend, then restart the server.',
      };
    }

    const model = this.normalizeModelName(
      this.config.get<string>('GEMINI_MODEL') ?? 'gemini-2.0-flash',
    );
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/${model}:generateContent`,
      {
        method: 'POST',
        headers: {
          'x-goog-api-key': apiKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          systemInstruction: {
            parts: [
              {
                text: 'You are NutriNepal AI, a warm, conversational nutrition and fitness assistant for Nepalese adults. Behave like a helpful AI chat companion: answer directly, remember the recent conversation, ask one useful follow-up question when needed, and keep responses practical. Prefer Nepal-friendly foods, simple workouts, and realistic habits. Do not diagnose disease or replace a doctor. For medical symptoms, eating disorder risk, extreme dieting, or dangerous requests, advise consulting a qualified clinician.',
              },
            ],
          },
          contents: [
            ...this.toGeminiHistory(history),
            {
              role: 'user',
              parts: [
                {
                  text: `User context: name=${user.firstName ?? 'User'}, fitnessGoal=${user.fitnessGoal ?? 'not set'}, age=${user.age ?? 'not set'}, weightKg=${user.weight ?? 'not set'}, heightCm=${user.height ?? 'not set'}.\n\nQuestion: ${message}`,
                },
              ],
            },
          ],
        }),
      },
    ).catch(() => {
      throw new ServiceUnavailableException(
        'I could not reach the AI service right now. Please check your internet connection and try again.',
      );
    });

    const data = (await response.json()) as GeminiResponse;
    if (!response.ok) {
      this.throwGeminiError(response.status, data.error);
    }

    return {
      reply:
        data.candidates?.[0]?.content?.parts
          ?.map((part) => part.text ?? '')
          .join('')
          .trim() || 'I could not generate a useful answer. Please try again.',
    };
  }

  private toGeminiHistory(history: AiChatMessageDto[]) {
    return history.slice(-10).map((item) => ({
      role: item.role,
      parts: [{ text: item.text }],
    }));
  }

  private normalizeModelName(model: string) {
    const trimmed = model.trim().replace('gemini1.5', 'gemini-1.5');
    if (trimmed.startsWith('models/') || trimmed.startsWith('tunedModels/')) {
      return trimmed;
    }
    return `models/${trimmed}`;
  }

  private throwGeminiError(
    statusCode: number,
    error?: GeminiResponse['error'],
  ): never {
    const message = error?.message ?? '';
    const isQuotaError =
      statusCode === 429 ||
      error?.status === 'RESOURCE_EXHAUSTED' ||
      message.toLowerCase().includes('quota');

    if (isQuotaError) {
      throw new HttpException(
        'The AI chat limit has been reached for now. Please try again later, or update the Gemini API billing/quota settings on the backend.',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    throw new ServiceUnavailableException(
      'The AI service is unavailable right now. Please try again in a moment.',
    );
  }
}
