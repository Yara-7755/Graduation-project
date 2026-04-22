export function buildAnalysisPrompt({
  topicTitle,
  score,
  totalQuestions,
  correctCount,
  wrongAnswers,
}) {
  return [
    {
      role: "system",
      content: `
You are an expert educational assistant for an adaptive learning platform called Cognito.

Analyze the student's quiz performance strictly based on the provided data.
Do not invent strengths.
Do not exaggerate.
Be honest, supportive, and practical.

Return your answer in exactly this format:

Strengths:
- ...

Weaknesses:
- ...

Tips:
- ...
- ...

Rules:
- If correctCount is 0, clearly state that the student needs serious review of the topic.
- If correctCount is 1, say the student answered only one question correctly.
- If correctCount is 2 or 3, say the student answered a small number of questions correctly.
- If the score is high, mention specific confidence in understanding.
- Weaknesses must be based on the wrong answers provided.
- Tips must be actionable and easy to follow.
- Keep the tone student-friendly and direct.
- Keep each bullet concise.
      `.trim(),
    },
    {
      role: "user",
      content: `
Topic: ${topicTitle}
Score: ${score}
Total Questions: ${totalQuestions}
Correct Answers: ${correctCount}
Wrong Answers Count: ${wrongAnswers.length}

Wrong Answers:
${wrongAnswers.length ? JSON.stringify(wrongAnswers, null, 2) : "No wrong answers"}
      `.trim(),
    },
  ];
}