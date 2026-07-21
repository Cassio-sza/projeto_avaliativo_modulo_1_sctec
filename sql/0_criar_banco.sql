DROP DATABASE IF EXISTS transparencia;

CREATE DATABASE IF NOT EXISTS transparencia 
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE transparencia;


-- =============================================================
-- Criação das tabelas RAW 
-- =============================================================

DROP TABLE IF EXISTS raw_viagem;
CREATE TABLE raw_viagem (
    id_viagem VARCHAR(50),
    num_proposta VARCHAR(20),
    situacao VARCHAR (50),
    viagem_urgente VARCHAR(5),
    just_viagem_urg VARCHAR(4000),
    cod_orgao_superior VARCHAR(20),
    nome_orgao_superior VARCHAR(255),
    cod_orgao_solicitante VARCHAR(20),
    nome_orgao_solicitante VARCHAR(255),
    cpf_viajante varchar(20),
    nome_viajante varchar(255),
    cargo VARCHAR(255),
    funcao varchar(255),
    descricao_funcao varchar(255),
    data_inicio varchar(10),
    data_fim varchar(10),
    destinos varchar(4000),
    motivo varchar(4000),
    valor_diarias varchar(20),
    valor_passagens varchar(20),
    valor_devolucao varchar(20),
    valor_outros_gastos varchar(20)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC;

DROP TABLE IF EXISTS raw_passagem;
CREATE TABLE raw_passagem(
    id_viagem varchar(50),
    num_proposta varchar(20),
    meio_transporte varchar(50),
    pais_origem_ida varchar(60),
    uf_origem_ida varchar(40),
    cidade_origem_ida varchar(80),
    pais_destino_ida varchar(60),
    uf_destino_ida varchar(40),
    cidade_destino_ida varchar(80),
    pais_origem_volta varchar(80),
    uf_origem_volta varchar(40),
    cidade_origem_volta varchar(40),
    pais_destino_volta varchar(60),
    uf_destino_volta varchar(40),
    cidade_destino_volta varchar(80),
    valor_passagem varchar(20),
    taxa_servico varchar(20),
    data_emissao varchar(10),
    hora_emissao varchar(10)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS raw_pagamento;
CREATE TABLE raw_pagamento(
    id_viagem varchar(50),
    num_proposta varchar(20),
    cod_orgao_superior varchar(20),
    nome_orgao_superior varchar(255),
    cod_orgao_pagador varchar(20),
    nome_orgao_pagador varchar(255),
    cod_ug_pagadora varchar(20),
    nome_ug_pagadora varchar(4000),
    tipo_pagamento varchar(50),
    valor varchar(20)
) ENGINE=InnoDB;


DROP TABLE IF EXISTS raw_trecho;
CREATE TABLE raw_trecho(
    id_viagem varchar(50),
    num_proposta varchar(20),
    sequencia_trecho varchar(40),
    origem_data varchar(10),
    origem_pais varchar(40),
    origem_uf varchar(40),
    origem_cidade varchar(80),
    destino_data varchar(10),
    destino_pais varchar(40),
    destino_uf varchar(40),
    destino_cidade varchar(80),
    meio_transporte varchar(80),
    numero_diarias varchar(10),
    missao varchar(400)
) ENGINE=InnoDB;

-- =============================================================
-- Criação das tabelas Silver
-- =============================================================
DROP table if exists silver_viagem;
CREATE TABLE silver_viagem (
    id_viagem VARCHAR(50) NOT NULL,
    num_proposta VARCHAR(20),
    situacao VARCHAR(50),
    viagem_urgente VARCHAR(5),
    cod_orgao_superior VARCHAR(20),
    nome_orgao_superior VARCHAR(255) NOT NULL,
    nome_viajante VARCHAR(255),
    cargo VARCHAR(255),
    periodo_data_inicio DATE,                   -- convertido de DD/MM/AAAA
    periodo_data_fim DATE,                      -- convertido de DD/MM/AAAA
    destinos VARCHAR(4000),
    motivo VARCHAR(4000),
    valor_diarias DECIMAL(10,2),        -- CHECK >=0
    valor_passagens DECIMAL(10,2),
    valor_devolucao DECIMAL(10,2),
    valor_outros_gastos DECIMAL(10,2),
    valor_total DECIMAL(12,2),                  -- calculado
    duracao_dias INT,                        -- calculado
    
    PRIMARY KEY (id_viagem),
    
    CONSTRAINT chk_diarias CHECK (valor_diarias >= 0)
)ENGINE=InnoDB ROW_FORMAT=DYNAMIC;

DROP TABLE IF EXISTS silver_passagem;
CREATE TABLE silver_passagem (
    id_passagem INT AUTO_INCREMENT,
    id_viagem VARCHAR(50) NOT NULL,
    meio_transporte VARCHAR(50),
    pais_origem_ida VARCHAR(60),
    uf_origem_ida VARCHAR(40),
    cidade_origem_ida VARCHAR(80),
    pais_destino_ida VARCHAR(60),
    uf_destino_ida VARCHAR(40),
    cidade_destino_ida VARCHAR(80),
    valor_passagem DECIMAL(10,2),
    taxa_servico DECIMAL(10,2),
    data_emissao DATE,
    
    PRIMARY KEY (id_passagem),
    FOREIGN KEY (id_viagem) REFERENCES silver_viagem(id_viagem),
    
    CONSTRAINT chk_valor_passagem CHECK (valor_passagem >= 0),
    CONSTRAINT chk_taxa_servico CHECK (taxa_servico >= 0)
    
) ENGINE=InnoDB;

DROP TABLE IF EXISTS silver_pagamento;
CREATE TABLE silver_pagamento (
    id_pagamento INT AUTO_INCREMENT,
    id_viagem VARCHAR(50) NOT NULL,
    num_proposta VARCHAR(20),
    nome_orgao_pagador VARCHAR(255),
    nome_ug_pagadora VARCHAR(255),
    tipo_pagamento VARCHAR(50) NOT NULL,
    valor DECIMAL(10,2),
    
    PRIMARY KEY (id_pagamento),
    FOREIGN KEY (id_viagem) REFERENCES silver_viagem(id_viagem),
    
    CONSTRAINT chk_valor CHECK (valor >= 0)
)ENGINE=InnoDB;

DROP TABLE IF EXISTS silver_trecho;
CREATE TABLE silver_trecho (
    id_trecho INT AUTO_INCREMENT,
    id_viagem VARCHAR(50) NOT NULL,
    sequencia_trecho INT,
    origem_data DATE,
    origem_uf VARCHAR(40), 
    origem_cidade VARCHAR(80),
    destino_data DATE,
    destino_uf VARCHAR(40),
    destino_cidade VARCHAR(80),
    meio_transporte VARCHAR(50),
    numero_diarias DECIMAL(10,2),
    
    PRIMARY KEY (id_trecho),
    FOREIGN KEY (id_viagem) REFERENCES silver_viagem(id_viagem),
    
    CONSTRAINT uk_viagem_sequencia UNIQUE (id_viagem, sequencia_trecho),
    CONSTRAINT chk_num_diarias CHECK (numero_diarias >= 0)
) ENGINE=InnoDB;