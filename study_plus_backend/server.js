const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

console.log("STARTING SERVER");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const projects = [];
const inviteCodes = {};

app.get("/", (req, res) => {
  res.send("Backend works with Gemini");
});

app.post("/generate-plan", async (req, res) => {
  try {
    const { title, details } = req.body;

    if (!title || !details) {
      return res.status(400).json({
        error: "Project title and details are required",
      });
    }

    const prompt = `
Create a structured 8-week software project plan.

Project name: ${title}

Project details:
${details}

Return ONLY valid JSON.
Do not include markdown.
Do not include explanations.
Do not wrap the JSON in triple backticks.

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
- Use days 1 to 5.
- Make the plan realistic for a student software/app development project.
- Include planning, UI/UX, frontend, backend, database, AI integration, testing, and final presentation/deployment.
- Return only JSON.
`;

    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
    });

    let aiText = response.text
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    const json = JSON.parse(aiText);

    const projectId = Date.now().toString();

    const randomPart = Math.random()
      .toString(36)
      .substring(2, 6)
      .toUpperCase();

    const inviteCode = `PROJ-${new Date().getFullYear()}-${randomPart}`;

    const project = {
      id: projectId,
      title,
      details,
      inviteCode,
      tasks: json.tasks,
    };

    projects.push(project);
    inviteCodes[inviteCode] = projectId;

    res.json(project);
  } catch (error) {
    console.error("Gemini generation error:", error);

    res.status(500).json({
      error: "Failed to generate plan",
    });
  }
});

app.get("/projects/:projectId", (req, res) => {
  const project = projects.find((p) => p.id === req.params.projectId);

  if (!project) {
    return res.status(404).json({
      error: "Project not found",
    });
  }

  res.json(project);
});

app.post("/projects/:projectId/invite-code", (req, res) => {
  const project = projects.find((p) => p.id === req.params.projectId);

  if (!project) {
    return res.status(404).json({
      error: "Project not found",
    });
  }

  res.json({
    projectId: project.id,
    inviteCode: project.inviteCode,
  });
});

app.post("/teams/join-by-code", (req, res) => {
  const { joinCode } = req.body;

  if (!joinCode) {
    return res.status(400).json({
      error: "Join code is required",
    });
  }

  const projectId = inviteCodes[joinCode];

  if (!projectId) {
    return res.status(400).json({
      error: "Invalid invite code",
    });
  }

  const project = projects.find((p) => p.id === projectId);

  if (!project) {
    return res.status(404).json({
      error: "Project not found",
    });
  }

  res.json(project);
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});