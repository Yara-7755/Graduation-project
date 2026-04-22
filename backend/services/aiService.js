import fetch from "node-fetch";

export async function callAI(messages) {
  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${process.env.AI_API_KEY}`,
      },
      body: JSON.stringify({
        model: process.env.AI_MODEL || "gpt-4o-mini",
        messages,
        temperature: 0.7,
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("OPENAI API ERROR:", data);
      throw new Error(data?.error?.message || "AI request failed");
    }

    const content = data?.choices?.[0]?.message?.content;

    if (!content || typeof content !== "string") {
      throw new Error("No content returned from AI");
    }

    return content.trim();
  } catch (error) {
    console.error("AI SERVICE ERROR:", error.message);
    return "AI service is currently unavailable.";
  }
}