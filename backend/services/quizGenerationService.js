import crypto from "crypto";
import { callAI } from "./aiService.js";
import { buildCodeQuizPrompt } from "../prompts/codeQuizPrompt.js";

export function createQuestionHash(question) {
  const normalized = [
    question.question_text || "",
    question.code_snippet || "",
    question.option_a || "",
    question.option_b || "",
    question.option_c || "",
    question.option_d || "",
    question.question_type || "",
  ]
    .join(" | ")
    .replace(/\s+/g, " ")
    .trim()
    .toLowerCase();

  return crypto.createHash("sha256").update(normalized).digest("hex");
}

export function inferWeaknessTag(question, topicTitle, fieldName) {
  const baseText = `
    ${topicTitle || ""}
    ${fieldName || ""}
    ${question.question_text || ""}
    ${question.code_snippet || ""}
  `
    .toLowerCase()
    .trim();

  if (baseText.includes("loop") || baseText.includes("for") || baseText.includes("while")) {
    return "loops";
  }

  if (baseText.includes("function") || baseText.includes("return")) {
    return "functions";
  }

  if (baseText.includes("array")) {
    return "arrays";
  }

  if (baseText.includes("object")) {
    return "objects";
  }

  if (
    baseText.includes("react") ||
    baseText.includes("state") ||
    baseText.includes("props") ||
    baseText.includes("jsx")
  ) {
    return "react_basics";
  }

  if (
    baseText.includes("express") ||
    baseText.includes("route") ||
    baseText.includes("middleware") ||
    baseText.includes("request") ||
    baseText.includes("response")
  ) {
    return "backend_routes";
  }

  if (
    baseText.includes("async") ||
    baseText.includes("await") ||
    baseText.includes("promise")
  ) {
    return "async_logic";
  }

  if (
    baseText.includes("flutter") ||
    baseText.includes("widget") ||
    baseText.includes("dart") ||
    baseText.includes("navigation")
  ) {
    return "mobile_basics";
  }

  return "general";
}

export function getDifficultyStep(level, wrongHistoryCount) {
  if (level === "Beginner") {
    if (wrongHistoryCount >= 6) return 1;
    if (wrongHistoryCount >= 3) return 2;
    return 3;
  }

  if (level === "Intermediate") {
    if (wrongHistoryCount >= 6) return 1;
    if (wrongHistoryCount >= 3) return 2;
    return 3;
  }

  if (wrongHistoryCount >= 6) return 1;
  if (wrongHistoryCount >= 3) return 2;
  return 3;
}

export async function generateCodeQuiz({
  topicTitle,
  level,
  fieldName,
  count = 5,
  excludedQuestions = [],
  weakAreas = [],
  difficultyStep = 1,
}) {
  const variationSeed = `${Date.now()}-${Math.floor(Math.random() * 100000)}`;

  const messages = buildCodeQuizPrompt({
    topicTitle,
    level,
    fieldName,
    variationSeed,
    count,
    excludedQuestions,
    weakAreas,
    difficultyStep,
  });

  const aiText = await callAI(messages);

  if (!aiText || aiText === "AI service is currently unavailable.") {
    throw new Error("AI service unavailable");
  }

  try {
    const cleaned = aiText.replace(/```json|```/g, "").trim();
    const parsed = JSON.parse(cleaned);

    if (!Array.isArray(parsed)) {
      throw new Error("Generated quiz is not an array");
    }

    return parsed.map((question) => ({
      ...question,
      question_hash: createQuestionHash(question),
      weakness_tag: inferWeaknessTag(question, topicTitle, fieldName),
      difficulty_step: difficultyStep,
    }));
  } catch (error) {
    console.error("QUIZ JSON PARSE ERROR:", aiText);
    throw new Error("Failed to parse generated quiz");
  }
}