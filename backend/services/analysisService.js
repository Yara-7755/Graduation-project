import { callAI } from "./aiService.js";
import { buildAnalysisPrompt } from "../prompts/analysisPrompt.js";

export async function analyzeQuizPerformance({
  topicTitle,
  score,
  totalQuestions,
  correctCount,
  wrongAnswers,
}) {
  const messages = buildAnalysisPrompt({
    topicTitle,
    score,
    totalQuestions,
    correctCount,
    wrongAnswers,
  });

  const aiText = await callAI(messages);

  if (!aiText || aiText === "AI service is currently unavailable.") {
    return "Strengths:\n- Quiz completed.\n\nWeaknesses:\n- Detailed AI analysis is currently unavailable.\n\nTips:\n- Review the topic again.\n- Focus on the questions you answered incorrectly.";
  }

  if (correctCount === 0) {
    return aiText.replace(
      /Strengths:\s*-\s*.*?(?=\n\nWeaknesses:|\nWeaknesses:|$)/s,
      `Strengths:
- You completed the quiz and now have a clear idea that this topic needs focused review.`
    );
  }

  return aiText;
}