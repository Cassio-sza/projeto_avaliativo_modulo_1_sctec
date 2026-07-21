import script.banco as banco

# =======================================================
# 1 - Esvaziar as tabelas SILVER
# =======================================================

# Limpeza para idempotência. Vamos remover os dados de forma decrescente na hierarquia.
LIMPAR_SILVER = [
    "DELETE FROM silver_pagamento",
    "DELETE FROM silver_passagem",
    "DELETE FROM silver_trecho",
    "DELETE FROM silver_viagem"
]

# =======================================================
# 2 - Copiar dados da tabela RAW para a SILVER
# =======================================================

SQL_VIAGEM = """
INSERT INTO silver_viagem (
    id_viagem, num_proposta, situacao, viagem_urgente, cod_orgao_superior, nome_orgao_superior,
    nome_viajante, cargo, periodo_data_inicio, periodo_data_fim, destinos, motivo, valor_diarias, valor_passagens,
    valor_devolucao, valor_outros_gastos
)
SELECT 
    TRIM(id_viagem), num_proposta, situacao, viagem_urgente, cod_orgao_superior, nome_orgao_superior,
    nome_viajante, cargo, 
    STR_TO_DATE(NULLIF(TRIM(data_inicio), ''), '%d/%m/%Y'), 
    STR_TO_DATE(NULLIF(TRIM(data_fim), ''), '%d/%m/%Y'), 
    destinos, motivo, 
    CAST(REPLACE(REPLACE(NULLIF(TRIM(valor_diarias), ''), '.', ''), ',', '.') AS DECIMAL(10,2)), 
    CAST(REPLACE(REPLACE(NULLIF(TRIM(valor_passagens), ''), '.', ''), ',', '.') AS DECIMAL(10,2)), 
    CAST(REPLACE(REPLACE(NULLIF(TRIM(valor_devolucao), ''), '.', ''), ',', '.') AS DECIMAL(10,2)), 
    CAST(REPLACE(REPLACE(NULLIF(TRIM(valor_outros_gastos), ''), '.', ''), ',', '.') AS DECIMAL(10,2))
FROM raw_viagem
"""

SQL_PAGAMENTO = """
INSERT INTO silver_pagamento (
    id_viagem, num_proposta, nome_orgao_pagador, nome_ug_pagadora, tipo_pagamento, valor
)
SELECT
    TRIM(id_viagem), num_proposta, nome_orgao_pagador, nome_ug_pagadora, tipo_pagamento, 
    CAST(REPLACE(REPLACE(NULLIF(TRIM(valor), ''), '.', ''), ',', '.') AS DECIMAL(10,2))
FROM raw_pagamento
WHERE TRIM(id_viagem) IN (SELECT id_viagem FROM silver_viagem);
"""

SQL_PASSAGEM = """
INSERT INTO silver_passagem (
    id_viagem, meio_transporte, pais_origem_ida, uf_origem_ida, cidade_origem_ida, pais_destino_ida,
    uf_destino_ida, cidade_destino_ida, valor_passagem, taxa_servico, data_emissao
)
SELECT
    TRIM(id_viagem), meio_transporte, pais_origem_ida, uf_origem_ida, cidade_origem_ida, pais_destino_ida,
    uf_destino_ida, cidade_destino_ida,
    CAST(REPLACE(REPLACE(NULLIF(TRIM(valor_passagem), ''), '.', ''), ',', '.') AS DECIMAL(10,2)), 
    CAST(REPLACE(REPLACE(NULLIF(TRIM(taxa_servico), ''), '.', ''), ',', '.') AS DECIMAL(10,2)), 
    STR_TO_DATE(NULLIF(TRIM(data_emissao), ''), '%d/%m/%Y')
FROM raw_passagem
WHERE TRIM(id_viagem) IN (SELECT id_viagem FROM silver_viagem);
"""

SQL_TRECHO = """
INSERT INTO silver_trecho (
    id_viagem, sequencia_trecho, origem_data, origem_uf, origem_cidade, destino_data, destino_uf,
    destino_cidade, meio_transporte, numero_diarias
)
SELECT 
    TRIM(id_viagem), 
    CAST(NULLIF(TRIM(sequencia_trecho), '') AS UNSIGNED), 
    STR_TO_DATE(NULLIF(TRIM(origem_data), ''), '%d/%m/%Y'), 
    origem_uf, origem_cidade, 
    STR_TO_DATE(NULLIF(TRIM(destino_data), ''), '%d/%m/%Y'), 
    destino_uf, destino_cidade, meio_transporte, 
    CAST(REPLACE(REPLACE(NULLIF(TRIM(numero_diarias), ''), '.', ''), ',', '.') AS DECIMAL(10,2))
FROM raw_trecho
WHERE TRIM(id_viagem) IN (SELECT id_viagem FROM silver_viagem);
"""

# =======================================================
# 3 - Calcular as colunas derivadas
# =======================================================

# AJUSTE: Adicionado WHERE para evitar problemas com travas do Safe Updates Mode do MySQL
SQL_CALC_VIAGENS = """
UPDATE silver_viagem
SET 
-- 1) Cálculo do Valor Total
    valor_total = COALESCE(valor_diarias, 0) + 
                  COALESCE(valor_passagens, 0) + 
                  COALESCE(valor_outros_gastos, 0) - 
                  COALESCE(valor_devolucao, 0),
                  
-- 2) Cálculo da Duração da Viagem em Dias
    duracao_dias = DATEDIFF(periodo_data_fim, periodo_data_inicio)
WHERE id_viagem IS NOT NULL
"""

# =======================================================
# 4 - Executar programa principal
# =======================================================

def main():
    print("=== Fase 2: TRANSFORMAR + CAMADA SILVER ===")
    try:
        conexao = banco.conectar()

        print('[1/3] Esvaziar as tabelas SILVER...')
        for comando in LIMPAR_SILVER:
            banco.executar(conexao, comando) 
            
        print('[2/3] Copiar e converter RAW -> SILVER...')
        banco.executar(conexao, SQL_VIAGEM)
        print('         silver_viagem OK')
        banco.executar(conexao, SQL_PAGAMENTO)
        print('         silver_pagamento OK')
        banco.executar(conexao, SQL_PASSAGEM)
        print('         silver_passagem OK')
        banco.executar(conexao, SQL_TRECHO)
        print('         silver_trecho OK')

        print('[3/3] Calcular valor_total e duracao_dias...')
        banco.executar(conexao, SQL_CALC_VIAGENS)

        conexao.commit()
        conexao.close()
        print('=== Etapa TRANSFORMAR concluída com sucesso! ===')
    except Exception as erro:
        print('[ERRO] Algo deu errado:', erro)
        raise

if __name__ == "__main__":
    main()