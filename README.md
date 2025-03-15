# Meu Recomendador de Receitas

Este projeto é um app de recomendação de receitas que usa:

- AWS Lambda (Go) para traduzir receitas.
- DynamoDB para armazenar receitas traduzidas.
- Terraform para gerenciar a infraestrutura.

## Como usar

1. Clone o repositório:
   ```bash
   git clone https://github.com/v-venes/dish-of-the-day.git
   ```
2. Configure as credenciais da AWS no arquivo infra/terraform.tfvars.
3. Aplique o Terraform:
   ```bash
   cd infra
   terraform init
   terraform apply
   ```
4. Para deploy automático, faça push para o branch `main`.
