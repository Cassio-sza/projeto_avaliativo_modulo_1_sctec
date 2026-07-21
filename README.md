# Projeto Avaliativo: Análise Exploratória de Dados - Portal da Transparência

- **Aluno:** Cássio Silva Souza
- **Curso:** Análise de dados com Python
- **Turma:** QA ADPY 2026/1 2

Este repositório contém a solução desenvolvida para o Projeto Avaliativo do Módulo 1 do curso de Análise de Dados com Python, focado na aplicação prática de técnicas de criação de pipeline de dados utilizando a Arquitetura Medallion (RAW, SILVER e GOLG), com criação de tabelas e gráficos para respoder a 7 perguntas de negócios tendo como base de dados de viagens a serviços, disponíveis no Portal da Tranparência do Governo Federal.

---

## Tecnologias e Ferramentas Utilizadas
* **Linguagem:** Python 3.13+
* **IDE:** Visual Studio Code (VS Code)
* **MySQL:** MySQL Workbrench
* **Bibliotecas:** 

  * `pandas` (Manipulação e tratamento de dados)
  * `matplotlib`(Criação de gráficos)
  * `warnings` (Otimização de exibição de logs do terminal)
  * `mysql-connector-python` (Driver de conexão com o banco)
  * `zipfile` (Manipulação de arquivos compactados .zip )

---

## Como Executar o Projeto

### Pré-requisitos
Antes de rodar o script, certifique-se de ter o Python instalado e as dependências necessárias. Você pode instalá-las executando no terminal:
```bash
pip install -r requirements.txt

```
Para rodar, execute o código no terminal nessamesma ordem:
```
mysql -u root -p < 0_criar_banco.sql
python 1_extrair.py
python 2_transformar.py
jupyter notebook 3_analise.ipynb
```
---
## Perguntas de negócio respondidas
1. Os 5 órgãos com maior custo total
2. Os 3 destinos com maior custo médio por viagem
3. A viagem de maior duração e seu custo total
4. Tipo de pagamento com maior valor médio
5. Meio de transporte mais usado nos trechos
6. UF de destino que mais aparece nos trechos
7. Órgão que mais pagou no total
- (GOLD) Custo por meio de transporte e situação da viagem
- (GOLD) Gasto em passagens por urgência da viagem
- (GOLD) Evolução mensal dos gastos com viagens 

---

## Principais Insights

* O Fundo Nacional de Segurança Pública lidera o ranking de gastos, à frente até de órgãos com estrutura de viagens muito maior.
* O fato do Órgão categorizado como 'Sigiloso' aparecer nas primeiras posições do ranking mostra uma limitação de transparência nos dados.
* Viagens marcadas como urgentes custam, em passagens, mais que o dobro das não urgentes.
* O gasto com passagens tem um pico claro entre março e junho, caindo drasticamente no segundo semestre.




