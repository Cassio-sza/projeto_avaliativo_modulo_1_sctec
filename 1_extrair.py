import pandas as pd
import gdown
import zipfile

import banco
import config

# ---------------------------------------------------------------------------
# Baixar o arquivo .zip do Drive
# ---------------------------------------------------------------------------

def baixar_zip ():
    """Baixa o aqruivo .zip do Google Drive"""
    config.PASTA_DADOS.mkdir(exist_ok=True)
    destino = config.PASTA_DADOS / ""

    if destino.exists():
        print('Arquivo existente - Pulando download!')
    else:
        print('Baixando o arquivo.')
        gdown.download(id=config.DRIVE_FILE_ID, output=str(destino))
    return destino


# ---------------------------------------------------------------------------
# 1 - Localizar o arquivo .zip na pasta data/
# ---------------------------------------------------------------------------

def localizar_zip():
    """Aponta para o transparencia.zip na pasta data/."""
    caminho = config.PASTA_DADOS / "transparencia.zip"
    if not caminho.exists():
        raise FileNotFoundError(
            "Arquivo nao encontrado: baixe o 'transparencia.zip' do Drive e "
            f"coloque-o na pasta '{config.PASTA_DADOS}' antes de rodar este script."
        )
    print("[1/3] Usando o arquivo local:", caminho.name)
    return caminho

# ---------------------------------------------------------------------------
# 2 - Carregar CSV dentro da tabela RAW
# ---------------------------------------------------------------------------

def carregar_csv(conexao, zip_aberto, nome_csv, tabela):
    # Le um CSV de dentro do zip e insere todas as linhas na tabela do MySQL.
    print("      Carregando", tabela, "...")

    # esvazia a tabela antes de carregar, evitando duplicidade ao rodar o código novamente
    banco.executar(conexao, f"TRUNCATE TABLE {tabela}")

    total = 0
    with zip_aberto.open(nome_csv) as arquivo:
        # le o CSV em pedacos, para nao encher a memoria do PC em bases grandes
        pedacos = pd.read_csv(
            arquivo,
            sep=";",                      # colunas separadas por ponto-e-virgula
            encoding="latin-1",           # acentuacao em latin-1
            dtype=str,                    # tudo como texto (camada RAW)
            keep_default_na=False,        # campo vazio continua "" (nao vira "NaN")
            chunksize=config.TAMANHO_BLOCO,
        )
        for pedaco in pedacos:
            linhas = pedaco.values.tolist()
            # um "%s" para cada coluna do CSV
            marcadores = ", ".join(["%s"] * len(pedaco.columns))
            comando = f"INSERT INTO {tabela} VALUES ({marcadores})"
            banco.inserir_em_lote(conexao, comando, linhas)
            total += len(linhas)

    print("      ->", total, "linhas em", tabela)


# ---------------------------------------------------------------------------
# Programa principal
# ---------------------------------------------------------------------------


def main():
    print("=== FASE 1: EXTRACAO + CAMADA RAW ===")
    try:
        conexao = banco.conectar()

        caminho_zip = localizar_zip()
        print("[2/3] Abrindo o arquivo zip...")
        print("[3/3] Carregando as tabelas RAW...")
        with zipfile.ZipFile(caminho_zip) as zip_aberto:
            for arquivo in config.ARQUIVOS.values():
                carregar_csv(conexao, zip_aberto, arquivo["csv"], arquivo["tabela_raw"])

        conexao.close()
        print("=== Camada RAW concluida com sucesso! ===")
    except Exception as erro:
        print("[ERRO] Algo deu errado:", erro)
        raise


if __name__ == "__main__":
    main()