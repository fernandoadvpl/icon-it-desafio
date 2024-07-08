
# APICAR01 - API de Consulta de Títulos a Receber

![API Status](https://img.shields.io/badge/status-active-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.0.0-blueviolet)
![Made with Love](https://img.shields.io/badge/made_with-love-red)

## Sumário

- [Descrição](#descrição)
- [Funcionalidades](#funcionalidades)
- [Como Utilizar](#como-utilizar)
- [Parâmetros](#parâmetros)
- [Exemplo de Chamada](#exemplo-de-chamada)
- [Resposta da API](#resposta-da-api)
- [Erros Comuns](#erros-comuns)
- [Instalação](#instalação)
- [Contribuição](#contribuição)
- [Licença](#licença)
- [Contato](#contato)

## Descrição

A **APICAR01** é uma API RESTful desenvolvida para fornecer uma maneira fácil e segura de acessar os dados dos títulos a receber do sistema Protheus. Com esta API, é possível consultar informações detalhadas sobre os títulos a receber utilizando critérios como empresa, filial, número da página e quantidade de registros por página.

## Funcionalidades

- Consultar títulos a receber
- Paginação dos resultados
- Filtragem por empresa e filial
- Autenticação segura via chave de API

## Como Utilizar

A API **APICAR01** pode ser acessada através do endpoint `/api/v1/getcar` utilizando o método HTTP GET. Para realizar uma consulta, forneça os parâmetros opcionais conforme necessário.

### Parâmetros

| Parâmetro | Tipo    | Descrição                    | Obrigatório |
|-----------|---------|------------------------------|-------------|
| page      | INTEGER | Número da página a ser retornada | Não         |
| pageSize  | INTEGER | Quantidade de registros por página | Não         |
| company   | STRING  | Código da Empresa            | Não         |
| branch    | STRING  | Código da Filial             | Não         |

### Exemplo de Chamada

```http
GET /api/v1/getcar?page=1&pageSize=10&company=99&branch=01
Authorization: Bearer [API_KEY]
```

### Autenticação

A API requer autenticação via chave de API. Inclua a chave no cabeçalho da requisição HTTP:

```http
Authorization: Bearer [API_KEY]
```

## Resposta da API

A resposta da API é fornecida no formato JSON e inclui detalhes sobre os títulos a receber, além de informações de paginação.

#### Exemplo de Resposta

```json
{
	"hasNext": true,
	"invoices": [
		{
			"branch": "01",
			"prefix": "FAT",
			"number": "000000001",
			"installment": "",
			"nature": "00010014",
			"type": "BOL",
			"issue": "08-07-24",
			"dueDate": "07-08-24",
			"actualDueDate": "07-08-24",
			"amount": 1500,
			"currency": "R$ 1.500,00"
		}
	],
	"totalRecords": 23,
	"currentPage": 1,
	"totalPages": 23
}
```

## Erros Comuns

- **403 Forbidden:**
  - **Mensagem:** "Acesso não autorizado! API Key inválida ou não informada."
  - **Causa:** A chave de API fornecida é inválida ou não foi fornecida.

- **400 Bad Request:**
  - **Mensagem:** "Empresa ou filial informada não é válida."
  - **Causa:** A empresa ou filial fornecida nos parâmetros não existe ou não é válida.

## Instalação

Para instalar e configurar o projeto localmente, siga os passos abaixo:

1. Clone o repositório:
    ```sh
    git clone https://github.com/seu-usuario/APICAR01.git
    ```

2. Navegue até o diretório do projeto:
    ```sh
    cd APICAR01
    ```

3. Instale as dependências:
    ```sh
    npm install
    ```

4. Configure as variáveis de ambiente conforme necessário.

5. Inicie o servidor:
    ```sh
    npm start
    ```

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests para melhorar o projeto. Por favor, siga as diretrizes de contribuição e o código de conduta.

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

## Contato

Para dúvidas ou mais informações, entre em contato:

- **Nome:** Fernando Alves
- **Email:** contato@fernandoalves.dev
- **LinkedIn:** (https://www.linkedin.com/in/fernandoalvessilva/)

---

Feito com ❤️ por (https://github.com/fernandoadvpl)
