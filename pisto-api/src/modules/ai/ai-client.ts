import OpenAI from 'openai'
import { env } from '../../config/env'

let _client: OpenAI | null = null

export function getAiClient(): OpenAI {
  if (!_client) {
    _client = new OpenAI({
      baseURL: env.AI_BASE_URL || undefined,
      apiKey: env.AI_API_KEY || 'no-key',
    })
  }
  return _client
}

export function getAiModel(): string {
  return env.AI_MODEL ?? 'gpt-4o'
}

// WHY tool-strict instead of response_format.json_schema: DeepSeek's response_format only supports 'text'/'json_object' (no schema enforcement), but its /beta endpoint honors `strict: true` on tool calls: same trick OpenAI supports, so it's portable across both providers.
export async function structuredCompletion<T>(
  { name, schema, maxTokens, messages }:
  { name: string; schema: Record<string, unknown>; maxTokens: number; messages: OpenAI.ChatCompletionMessageParam[] },
): Promise<T> {
  const model = getAiModel()
  const response = await getAiClient().chat.completions.create({
    model,
    max_tokens: maxTokens,
    tools: [{ type: 'function', function: { name, strict: true, parameters: schema } }],
    tool_choice: { type: 'function', function: { name } },
    // DeepSeek rejects forced tool_choice in thinking mode ("Thinking mode does not support
    // this tool_choice"); this field is DeepSeek-only, so only send it for deepseek models:
    // OpenAI's API rejects unrecognized request arguments.
    ...(model.startsWith('deepseek') ? { thinking: { type: 'disabled' } } : {}),
    messages,
  } as OpenAI.ChatCompletionCreateParamsNonStreaming)

  const toolCall = response.choices[0]?.message?.tool_calls?.[0]
  if (!toolCall || toolCall.type !== 'function') throw new Error(`AI did not return a tool call for ${name}`)
  return JSON.parse(toolCall.function.arguments) as T
}
