import axios from "axios";
import cors from "cors";
import express from "express";

const app = express();

app.use(cors());
app.use(express.json());

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

    if (!descricao) {
      return res.status(500).json({
        erro: "A IA não retornou uma descrição válida.",
      });
    }

    return res.json({
      descricao,
    });
  } catch (error) {
    console.error("Erro ao gerar descrição:", error.message);

    return res.status(500).json({
      erro: "Erro ao gerar descrição.",
    });
  }
});

app.listen(3000, () => {
  console.log("Backend IA rodando em http://localhost:3000");
});
