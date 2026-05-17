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

const buildSearchPrompt = (query, products) => `
Voce e uma IA de busca para um aplicativo de farmacia.

Consulta do cliente: ${query}

Produtos disponiveis:
${JSON.stringify(products, null, 2)}

Tarefa:
- Entenda a intencao da busca, inclusive sintomas simples, termos populares e erros de digitacao.
- Escolha apenas produtos da lista fornecida.
- Priorize produtos cujo nome, categoria ou descricao tenham relacao clara com a consulta.
- Para "febre", priorize apenas produtos com relacao clara a antitermico, dipirona, paracetamol, ibuprofeno ou febre.
- Para "dor de cabeca", priorize apenas produtos com relacao clara a analgesico, dipirona, paracetamol, ibuprofeno ou dor.
- Para "azia", "queimacao" ou "refluxo", priorize apenas produtos com relacao clara a estomago, refluxo, azia, omeprazol ou pantoprazol.
- Para "alergia" ou "rinite", priorize apenas produtos com relacao clara a antialergico, loratadina, desloratadina ou cetirizina.
- Para "enjoo", "nausea" ou "vomito", priorize apenas produtos com relacao clara a enjoo, nausea, vomito, dimenidrinato ou dramin.
- Nao retorne anticoncepcional, antialergico, enjoo, nausea, vitaminas, cosmeticos ou higiene quando a consulta for febre ou dor de cabeca, a menos que a consulta cite isso explicitamente.
- Nao retorne produtos apenas porque sao remedios. A relacao precisa ser com o problema pesquisado.
- Ignore palavras genericas da consulta como remedio, remedios, pra, para, quero, preciso, algo e tomar.
- Nao use apenas a categoria "medicamentos" como motivo para incluir um produto.
- Nao invente produtos, diagnosticos, tratamentos ou promessas de cura.
- Se nao houver relacao clara, retorne ids vazio.
- Retorne no maximo 12 ids, em ordem de relevancia.

Responda somente um JSON valido neste formato:
{
  "ids": ["id-do-produto"],
  "termos": ["termo relacionado"],
  "categorias": ["categoria relacionada"]
}
`;

const parseJsonFromAiResponse = (text) => {
  const rawText = String(text || "")
    .replace(/```json/gi, "")
    .replace(/```/g, "")
    .trim();

  try {
    const parsed = JSON.parse(rawText);
    if (parsed?.ids || parsed?.productIds) {
      return parsed;
    }
  } catch (_) {
  }

  for (let startIndex = 0; startIndex < rawText.length; startIndex += 1) {
    if (rawText[startIndex] !== "{") {
      continue;
    }

    let depth = 0;

    for (let endIndex = startIndex; endIndex < rawText.length; endIndex += 1) {
      if (rawText[endIndex] === "{") {
        depth += 1;
      }

      if (rawText[endIndex] === "}") {
        depth -= 1;
      }

      if (depth === 0) {
        try {
          const parsed = JSON.parse(rawText.slice(startIndex, endIndex + 1));
          if (parsed?.ids || parsed?.productIds) {
            return parsed;
          }
        } catch (_) {
        }

        break;
      }
    }
  }

  return null;
};

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

app.post("/buscar-produtos-inteligente", async (req, res) => {
  try {
    const consulta = String(req.body?.consulta || "").trim();
    const produtosRecebidos = Array.isArray(req.body?.produtos)
      ? req.body.produtos
      : [];

    if (!consulta) {
      return res.status(400).json({
        erro: "Consulta invalida.",
      });
    }

    if (produtosRecebidos.length === 0) {
      return res.status(400).json({
        erro: "Lista de produtos invalida.",
      });
    }

    const produtos = produtosRecebidos
      .map((produto) => ({
        id: String(produto?.id || "").trim(),
        nome: String(produto?.nome || "").trim(),
        categoria: String(produto?.categoria || "").trim(),
        descricao: String(produto?.descricao || "").trim(),
      }))
      .filter((produto) => produto.id && produto.nome)
      .slice(0, 80);

    if (produtos.length === 0) {
      return res.status(400).json({
        erro: "Nenhum produto valido recebido.",
      });
    }

    const idsPermitidos = new Set(produtos.map((produto) => produto.id));

    const resposta = await axios.post(
      "http://localhost:11434/api/generate",
      {
        model: "llama3.2",
        prompt: buildSearchPrompt(consulta, produtos),
        stream: false,
      },
      {
        timeout: 30000,
      }
    );

    const resultado = parseJsonFromAiResponse(resposta.data?.response);

    if (!resultado) {
      return res.status(500).json({
        erro: "A IA nao retornou uma busca valida.",
      });
    }

    const ids = (Array.isArray(resultado.ids)
      ? resultado.ids
      : Array.isArray(resultado.productIds)
      ? resultado.productIds
      : []
    )
      .map((id) => String(id).trim())
      .filter((id) => idsPermitidos.has(id))
      .slice(0, 12);

    const termos = Array.isArray(resultado.termos)
      ? resultado.termos.map((termo) => String(termo).trim()).filter(Boolean)
      : [];

    const categorias = Array.isArray(resultado.categorias)
      ? resultado.categorias
          .map((categoria) => String(categoria).trim())
          .filter(Boolean)
      : [];

    return res.json({
      ids,
      termos,
      categorias,
    });
  } catch (error) {
    console.error("Erro na busca inteligente:", error.message);

    return res.status(500).json({
      erro: "Erro ao buscar produtos com IA.",
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
