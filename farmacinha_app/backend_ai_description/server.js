import axios from "axios";
import cors from "cors";
import express from "express";
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const TOKEN_USAGE_FILE = path.join(__dirname, "token_usage.json");

app.use(cors());
app.use(express.json());

const emptyTokenUsage = () => ({
  promptTokens: 0,
  completionTokens: 0,
  totalTokens: 0,
  requestCount: 0,
});

const normalizeTokenUsage = (value) => {
  const promptTokens = Number(value?.promptTokens) || 0;
  const completionTokens = Number(value?.completionTokens) || 0;
  const requestCount = Number(value?.requestCount) || 0;

  return {
    promptTokens,
    completionTokens,
    totalTokens: promptTokens + completionTokens,
    requestCount,
  };
};

const readTotalTokenUsage = async () => {
  try {
    const fileContent = await fs.readFile(TOKEN_USAGE_FILE, "utf8");
    return normalizeTokenUsage(JSON.parse(fileContent));
  } catch (error) {
    if (error.code === "ENOENT") return emptyTokenUsage();
    throw error;
  }
};

const saveTotalTokenUsage = async (usage) => {
  await fs.writeFile(
    TOKEN_USAGE_FILE,
    JSON.stringify(normalizeTokenUsage(usage), null, 2),
    "utf8"
  );
};

const buildRequestTokenUsage = (ollamaResponse) => {
  const promptTokens = Number(ollamaResponse?.prompt_eval_count) || 0;
  const completionTokens = Number(ollamaResponse?.eval_count) || 0;

  return normalizeTokenUsage({
    promptTokens,
    completionTokens,
    requestCount: 1,
  });
};

const sumTokenUsage = (currentTotal, requestUsage) =>
  normalizeTokenUsage({
    promptTokens: currentTotal.promptTokens + requestUsage.promptTokens,
    completionTokens:
      currentTotal.completionTokens + requestUsage.completionTokens,
    requestCount: currentTotal.requestCount + 1,
  });

const buildPrompt = (productName) => `
Gere uma descrição profissional e curta para cadastro de produto de farmácia.

Produto: ${productName}

Regras:
- Use português do Brasil.
- Use linguagem simples.
- Gere no máximo 2 frases.
- Não prometa cura.
- Não dê diagnóstico.
- Não invente benefícios médicos exagerados.
- Não cite que foi gerado por IA.
- Retorne apenas a descrição, sem aspas e sem listas.
`;

app.post("/gerar-descricao", async (req, res) => {
  try {
    const nomeProduto = String(req.body?.nomeProduto || "").trim();

    if (!nomeProduto) {
      return res.status(400).json({
        erro: "Nome do produto inválido.",
      });
    }

    const resposta = await axios.post(
      "http://localhost:11434/api/generate",
      {
        model: "llama3.2",
        prompt: buildPrompt(nomeProduto),
        stream: false,
      },
      {
        timeout: 30000,
      }
    );

    const descricao = resposta.data?.response?.trim();
    const requestTokenUsage = buildRequestTokenUsage(resposta.data);
    const totalTokenUsage = sumTokenUsage(
      await readTotalTokenUsage(),
      requestTokenUsage
    );
    await saveTotalTokenUsage(totalTokenUsage);

    if (!descricao) {
      return res.status(500).json({
        erro: "A IA não retornou uma descrição válida.",
      });
    }

    return res.json({
      descricao,
      tokens: {
        entrada: requestTokenUsage.promptTokens,
        saida: requestTokenUsage.completionTokens,
        total: requestTokenUsage.totalTokens,
      },
      totalTokens: {
        entrada: totalTokenUsage.promptTokens,
        saida: totalTokenUsage.completionTokens,
        total: totalTokenUsage.totalTokens,
        requisicoes: totalTokenUsage.requestCount,
      },
    });
  } catch (error) {
    console.error("Erro ao gerar descrição:", error.message);

    return res.status(500).json({
      erro: "Erro ao gerar descrição.",
    });
  }
});

app.get("/uso-tokens", async (_req, res) => {
  try {
    const totalTokenUsage = await readTotalTokenUsage();

    return res.json({
      totalTokens: {
        entrada: totalTokenUsage.promptTokens,
        saida: totalTokenUsage.completionTokens,
        total: totalTokenUsage.totalTokens,
        requisicoes: totalTokenUsage.requestCount,
      },
    });
  } catch (error) {
    console.error("Erro ao consultar uso de tokens:", error.message);

    return res.status(500).json({
      erro: "Erro ao consultar uso de tokens.",
    });
  }
});

app.listen(3000, () => {
  console.log("Backend IA rodando em http://localhost:3000");
  console.log("Consultar uso de tokens em http://localhost:3000/uso-tokens");
});
