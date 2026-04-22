const fullySupportedCodeFields = [
  "Frontend Development",
  "Backend Development",
  "Programming Fundamentals",
  "Mobile Development",
];

function mapDifficulty(level) {
  if (level === "Beginner") return "easy";
  if (level === "Intermediate") return "medium";
  return "hard";
}

function getFieldInstructions(fieldName) {
  switch (fieldName) {
    case "Frontend Development":
      return `
Field Focus: Frontend Development
Use topics like:
- HTML
- CSS
- JavaScript
- DOM
- React basics
- state and props
- event handling
- component rendering
- conditional rendering
- form handling
      `.trim();

    case "Backend Development":
      return `
Field Focus: Backend Development
Use topics like:
- Node.js
- Express
- API routes
- middleware
- async/await
- request and response handling
- JSON
- server logic
- validation
- error handling
      `.trim();

    case "Programming Fundamentals":
      return `
Field Focus: Programming Fundamentals
Use topics like:
- variables
- data types
- conditions
- loops
- functions
- arrays
- objects
- basic logic
- simple algorithms
      `.trim();

    case "Mobile Development":
      return `
Field Focus: Mobile Development
Use topics like:
- Flutter basics
- Dart basics
- React Native basics
- state updates
- UI interaction
- widget/component logic
- navigation basics
- event handling
      `.trim();

    default:
      return `
Field Focus: General Programming
Use only simple topic-related code.
      `.trim();
  }
}

function getStepInstructions(level, difficultyStep) {
  if (level === "Beginner") {
    if (difficultyStep === 1) {
      return "Use very basic examples and very direct logic. Avoid nested logic.";
    }
    if (difficultyStep === 2) {
      return "Use beginner-level examples with slightly more reasoning, but keep them clear and short.";
    }
    return "Use stronger beginner-level questions with small traps, but stay within beginner scope.";
  }

  if (level === "Intermediate") {
    if (difficultyStep === 1) {
      return "Use easier intermediate questions with clear code and limited complexity.";
    }
    if (difficultyStep === 2) {
      return "Use normal intermediate questions with moderate reasoning.";
    }
    return "Use stronger intermediate questions with slightly deeper debugging or logic analysis.";
  }

  if (difficultyStep === 1) {
    return "Use easier advanced questions but keep them advanced in concept.";
  }
  if (difficultyStep === 2) {
    return "Use balanced advanced questions.";
  }
  return "Use stronger advanced questions with deeper reasoning, but keep them readable.";
}

export function buildCodeQuizPrompt({
  topicTitle,
  level,
  fieldName,
  variationSeed,
  count = 5,
  excludedQuestions = [],
  weakAreas = [],
  difficultyStep = 1,
}) {
  const difficulty = mapDifficulty(level);
  const isFullSupportField = fullySupportedCodeFields.includes(fieldName);

  const excludedBlock = excludedQuestions.length
    ? excludedQuestions.map((q, i) => `${i + 1}. ${q}`).join("\n")
    : "None";

  const weakAreasBlock = weakAreas.length ? weakAreas.join(", ") : "general";

  return [
    {
      role: "system",
      content: `
You are an expert programming instructor for an adaptive learning platform called Cognito.

Generate exactly ${count} different multiple-choice code questions.

Strict rules:
- Topic must closely match the given topic.
- Difficulty must match the student level.
- Stay inside the student's main level only.
- Do NOT generate a harder academic level than the given student level.
- You may only increase challenge gradually inside the same level.
- Questions must not repeat old questions or close paraphrases of old questions.
- Do not reuse the same examples, variable names, values, structures, or wording patterns.
- Make questions realistic, educational, and clear.
- Keep options plausible and distinct.
- correct_option must be exactly one of: A, B, C, or D.

Question type rules:
- Use a mix of:
  - output_prediction
  - find_the_error
  - code_logic
  - fill_the_blank
- At least one question must be output_prediction.
- At least one question must be find_the_error.

Each question must include exactly these fields:
- question_text
- code_snippet
- option_a
- option_b
- option_c
- option_d
- correct_option
- explanation
- question_type
- difficulty

Difficulty must be one of:
- easy
- medium
- hard

Return ONLY valid JSON array.
Do not use markdown.
Do not use triple backticks.
Do not add text before or after the JSON.
      `.trim(),
    },
    {
      role: "user",
      content: `
Topic: ${topicTitle}
Student Level: ${level}
Field Name: ${fieldName}
Difficulty Target: ${difficulty}
Difficulty Step Inside Same Level: ${difficultyStep}
Full Code Support: ${isFullSupportField ? "Yes" : "No"}
Variation Seed: ${variationSeed}
Question Count: ${count}
Priority Weak Areas: ${weakAreasBlock}

${getFieldInstructions(fieldName)}

Same-level challenge rule:
${getStepInstructions(level, difficultyStep)}

Do not repeat or closely resemble these previous questions:
${excludedBlock}

Extra instructions:
- Focus more on the weak areas when possible.
- Use fresh code examples.
- Keep code snippets short and readable.
- Make explanations concise and educational.
      `.trim(),
    },
  ];
}