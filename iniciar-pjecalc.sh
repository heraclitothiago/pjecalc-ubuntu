#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PJECALC_JAR="$SCRIPT_DIR/bin/pjecalc.jar"
if [ ! -f "$PJECALC_JAR" ]; then
    echo "Erro: JAR do PJe-Calc não encontrado: $PJECALC_JAR"
    echo "Instale a distribuição oficial do PJe-Calc Cidadão, incluindo bin/pjecalc.jar, e tente novamente."
    exit 1
fi

export PATH="$SCRIPT_DIR/navegador/windows:$PATH"

if [ -d "/usr/lib/jvm/java-8-openjdk-amd64" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
    JAVA_CMD="${JAVA_HOME}/jre/bin/java"
elif command -v java >/dev/null 2>&1; then
    JAVA_CMD="java"
else
    echo "Erro: Java não encontrado. Instale o openjdk-8-jre com: sudo apt install openjdk-8-jre"
    exit 1
fi

URL_PJECALC="http://localhost:9257/pjecalc/pages/principal.jsf"

echo "Iniciando o PJe-Calc Cidadão..."
echo "Diretório base: $SCRIPT_DIR"
echo "Usando binário Java: $JAVA_CMD"

# Executa o JAR com as configurações oficiais[cite: 1]
$JAVA_CMD \
  -splash:pjecalc_splash.gif \
  -Duser.timezone=GMT-3 \
  -Dfile.encoding=ISO-8859-1 \
  -Dseguranca.pjecalc.tokenServicos=pW4jZ4g9VM5MCy6FnB5pEfQe \
  -Dseguranca.pjekz.servico.contexto="https://pje.trtXX.jus.br/pje-seguranca" \
  -Xms1024m \
  -Xmx2048m \
  -XX:MaxPermSize=512m \
  -jar "$PJECALC_JAR" &

PJECALC_PID=$!

trap 'echo "Encerrando PJe-Calc..."; kill $PJECALC_PID 2>/dev/null; exit 0' SIGINT SIGTERM

echo "Aguardando servidor subir na porta 9257..."

ABERTO=0
while kill -0 $PJECALC_PID 2>/dev/null; do
    if [ $ABERTO -eq 0 ]; then
        # Testa especificamente a porta 9257
        if curl -s -I "http://localhost:9257/pjecalc" 2>/dev/null | grep -q "200\|302"; then
            echo "Servidor ativo! Abrindo interface..."
            sleep 2
            if ! pgrep -f "$URL_PJECALC" >/dev/null 2>&1; then
                firefox "$URL_PJECALC" &
            fi
            ABERTO=1
        fi
    fi
    sleep 2
done

wait $PJECALC_PID