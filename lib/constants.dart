// =============================================================================
// API CONSTANTS
// =============================================================================
// This file contains all API-related constants used throughout the application.
// These constants are used for making requests to OpenAI's APIs (ChatGPT and DALL-E)
// and configuring default application values.

// =============================================================================
// OpenAI API Base Configuration
// =============================================================================
// Base domain for all OpenAI API requests
const String apiDomain = 'api.openai.com';

// =============================================================================
// ChatGPT API Configuration
// =============================================================================
// Endpoint path for ChatGPT completions API
const String apiPathChatGpt = 'v1/chat/completions';

// Model identifier for ChatGPT - currently using GPT-4o
const String apiModelChatGpt = 'gpt-4o';


// =============================================================================
// DALL-E API Configuration
// =============================================================================
// Endpoint path for DALL-E image generation API
const String apiPathDalle = 'v1/images/generations';

// Model identifier for DALL-E - currently using DALL-E 3
const String apiModelDalle = 'dall-e-3';

// =============================================================================
// Application Default Values
// =============================================================================
// Default geographic area used when no specific area is provided
const String defaultArea = "東京";
