# Smart Transcription Feature

## Overview

The Smart Transcription feature enhances regular transcriptions by applying intelligent formatting using an additional LLM layer from the Groq API. When enabled, transcribed text is processed to interpret and apply embedded formatting instructions.

## Features

Smart Transcription can automatically:

- **Convert emoji mentions to actual emojis**: "heart emoji" → ❤️
- **Apply text casing**: "in all caps excited" → "EXCITED"
- **Format numbered lists**: "number 1 apples, number 2 bananas" → proper numbered list
- **Format email addresses**: "john dot doe at email dot com" → john.doe@email.com
- **Remove meta-instructions**: Cleans up formatting cues from the final output

## How to Enable

1. Open the app settings
2. Navigate to **Transcription Settings**
3. Find the **Smart Transcription** section
4. Toggle the switch to enable the feature

## Examples

### Emoji Conversion
- **Input**: "I'm so excited heart emoji muscle emoji"
- **Output**: "I'm so excited ❤️💪"

### Text Casing
- **Input**: "In all caps remember this! In normal casing this is important."
- **Output**: "REMEMBER THIS! This is important."

### Numbered Lists
- **Input**: "My grocery list: number 1 apples, number 2 bananas, number 3 milk"
- **Output**: 
  ```
  My grocery list:
  1. Apples
  2. Bananas
  3. Milk
  ```

### Email Formatting
- **Input**: "Send the file to jane dot doe at example dot com"
- **Output**: "Send the file to [jane.doe@example.com](mailto:jane.doe@example.com)"

## Technical Details

- **Model Used**: llama-3.3-70b-versatile (Groq API)
- **Fallback**: If smart transcription fails, the original transcription is used
- **API Endpoint**: `https://api.groq.com/openai/v1/chat/completions`
- **Processing**: Non-streaming for reliability

## Requirements

- Valid Groq API key
- Internet connection for API calls
- Smart Transcription toggle enabled in settings

## Error Handling

The feature is designed to be robust:
- If the API call fails, the original transcription is preserved
- Network errors don't affect the basic transcription functionality
- Invalid API responses fall back to the original text

## Performance

- Adds minimal processing time (typically 1-3 seconds)
- Processes transcriptions sequentially after initial transcription
- Uses the same API key as regular transcription 