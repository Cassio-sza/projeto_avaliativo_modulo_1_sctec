CREATE DATABASE IF NOT EXISTS transparencia 
	CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE transparencia;

show tables;

-- =============================================================
-- Criação das tabelas RAW 
-- =============================================================

CREATE TABLE viagem (
	id_viagem VARCHAR(20),
    num_proposta VARCHAR(20),
    situacao VARCHAR (50),
    viagem_urgente VARCHAR(5),
    just_viagem_urg VARCHAR(255),
    cod_orgao_superior VARCHAR(20),
    nome_orgao_superior VARCHAR(255),
    cod_orgao_solicitante VARCHAR(20),
    nome_orgao_solicitante VARCHAR(255),
    cpf_viajante varchar(20),
    nome varchar(255),
    cargo VARCHAR(255),
    funcao varchar(255),
	descricao_funcao varchar(255),
    periodo_data_inicio varchar(10),
    periodo_data_fim varchar(10),
    destinos varchar(255),
    motivo varchar(255),
    valor_diaria varchar(20),
    valor_passagem varchar(20),
    valor_devolucao varchar(20),
    valor_outros_gastos varchar(20)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC;

CREATE TABLE passagem(
	id_passagem varchar(10),
	id_proposta varchar(10),
	meio_transporte varchar(50),
	pais_origem_ida varchar(60),
	uf_origem_ida varchar(40),
	cidade_origem_ida varchar(80),
	pais_destino_ida varchar(60),
	uf_destino_ida varchar(40),
	cidade_destino_ida varchar(80),
	pais_origem_ida varchar(40),
	uf_origem_volta varchar(40),
    cidade_origem_volta varchar(40),
    pais_destino_volta varchar(60),
    uf_destino_volta varchar(40),
    cidade_destino_volta varchar(80),
    valor_passagem varchar(20),
	taxa_servico varchar(20),
    data_emissao varchar (10),
    hora_emissao varchar (10)
) ENGINE=InnoDB;

CREATE TABLE pagamento(
	id_pagamento varchar(10),
    id_proposta varchar(10),
    cod_orgao_superior varchar(20),
    nome_orgao_superior varchar(255),
    cod_orgao_pagador varchar(20),
    nome_orgao_pagador varchar(255),
    cod_up_pagadora varchar(20),
    nome_up_pagadora varchar(20),
    tipo_pagamento varchar(50),
	valor varchar(10)
) ENGINE=InnoDB;

CREATE TABLE trecho(
	id_trecho varchar(10),
    id_proposta varchar(10),
    sequencia_trecho varchar(40),
    origem_data varchar(10),
    origem_pais varchar(40),
    origem_uf varchar(40),
    origem_cidade varchar(80),
    origem_data varchar(10),
    destino_data varchar(10),
    destino_pais varchar(40),
    destino_uf varchar(40),
    destino_cidade varchar(80),
    meio_transporte varchar(80),
    numero_diarias varchar(10),
    missao varchar(400)
) ENGINE=InnoDB;