const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const OpenAI = require("openai").default;

console.log("STARTING SERVER");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

app.get("/", (req, res) => {
  res.send("Backend works");
});

app.post("/generate-plan", async (req, res) => {
  try {
    const { title, details } = req.body;

    const prompt = `
Create a structured 8-week project plan.

Project name: ${title}

Project details:
${details}

Return ONLY valid JSON.
Do not include markdown.
Do not include explanations.

JSON format:
{
  "tasks": [
    {
      "week": 1,
      "day": 1,
      "title": "Task title",
      "description": "Task description",
      "category": "planning",
      "estimated_hours": 2
    }
  ]
}

Requirements:
- Create tasks for weeks 1 to 8.
- Each week must have at least 3 tasks.
- Use days 1 to 5 for each week.
- Make the tasks practical for software/app development.
- Include planning, UI/UX, frontend, backend, AI integration, testing, and final presentation/deployment.
`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: "You are a project planning assistant. Always return only valid JSON.",
        },
        {
          role: "user",
          content: prompt,
        },
      ],
      temperature: 0.4,
    });

    const aiText = completion.choices[0].message.content;
    const json = JSON.parse(aiText);

    res.json(json);
  } catch (error) {
    console.error("AI generation error:", error);
    res.status(500).json({
      error: "Failed to generate plan",
    });
  }
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});