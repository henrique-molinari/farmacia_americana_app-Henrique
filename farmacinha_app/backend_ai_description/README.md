# Backend IA com Ollama

Backend intermediário usado pelo Flutter para gerar descrições curtas de produtos de farmácia usando Ollama local com o modelo `llama3.2`.

## Requisitos

- Node.js instalado
- Ollama instalado
- Modelo `llama3.2` baixado

## Baixar modelo

```bash
ollama pull llama3.2
```

## Verificar se Ollama está rodando

Acesse:

```text
http://localhost:11434
```

Deve aparecer:

```text
Ollama is running
```

No Windows, o Ollama normalmente já roda em segundo plano. Se a porta `11434` já estiver em uso ao executar `ollama serve`, significa que o Ollama provavelmente já está aberto.

## Como rodar

```bash
cd backend_ai_description
npm install
npm start
```

O servidor fica disponível em:

```text
http://localhost:3000
```

## Endpoint

```http
POST http://localhost:3000/gerar-descricao
Content-Type: application/json
```

Body:

```json
{
  "nomeProduto": "Dipirona 500mg"
}
```

Resposta:

```json
{
  "descricao": "Descrição gerada."
}
```

## Teste manual

No Prompt de Comando do Windows:

```cmd
curl -X POST http://localhost:3000/gerar-descricao ^
-H "Content-Type: application/json" ^
-d "{\"nomeProduto\":\"Dipirona 500mg\"}"
```

No PowerShell:

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:3000/gerar-descricao" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"nomeProduto":"Dipirona 500mg"}'
```

## Flutter

No Android Emulator, use:

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

No celular físico, troque para o IP local do computador:

```dart
static const String baseUrl = 'http://192.168.0.10:3000';
```
