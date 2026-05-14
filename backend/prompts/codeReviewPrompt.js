const supportedCodeReviewFields = [
  "Frontend Development",
  "Backend Development",
  "Programming Fundamentals",
  "Mobile Development",
];

export function isSupportedCodeReviewField(fieldName) {
  return supportedCodeReviewFields.includes(fieldName);
}

export function buildCodeReviewPrompt({ fieldName, language, code }) {
  return [
    {
      role: "system",
      content: `
You are an expert programming tutor in Cognito learning platform.

You review learner code and return ONLY valid JSON.

JSON structure:
{
  "hasErrors": true,
  "errors": [],
  "correctedCode": "",
  "explanation": "",
  "tips": []
}

Rules:
- Do not use markdown.
- Do not wrap JSON in code blocks.
- Detect syntax errors, logic errors, bad practices, and missing parts.
- Correct the code.
- Explain clearly and briefly.
- Keep the answer educational for a student.
      `.trim(),
    },
    {
      role: "user",
      content: `
Field: ${fieldName}
Language: ${language}

Review this code:

${code}
      `.trim(),
    },
  ];
}