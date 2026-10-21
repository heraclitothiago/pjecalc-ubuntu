
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PJECALC_JAR="$SCRIPT_DIR/bin/pjecalc.jar"

if [ ! -f "$PJECALC_JAR" ]; then
    echo "Erro: JAR do PJe-Calc não encontrado: $PJECALC_JAR"
    exit 1
fi

export PATH="$SCRIPT_DIR/navegador/windows:$PATH"

# Localização do Java 8
if [ -x "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java" ]; then
    JAVA_CMD="/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java"
elif [ -x "/usr/lib/jvm/java-8-openjdk-amd64/bin/java" ]; then
    JAVA_CMD="/usr/lib/jvm/java-8-openjdk-amd64/bin/java"
elif command -v java >/dev/null 2>&1; then
    JAVA_CMD="java"
else
    echo "Erro: Java não encontrado."
    exit 1
fi

URL_PJECALC="http://localhost:9257/pjecalc/pages/principal.jsf"
PJECALC_PID=""
SOCAT_PID=""

# Identifica o IP principal da rede local
IP_LOCAL="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '
    /src/ {
        for (i=1; i<=NF; i++)
            if ($i=="src") {print $(i+1); exit}
    }'
)"

# Encerramento dos processos
encerrar() {
    trap - EXIT INT TERM

    echo ""
    echo "Encerrando PJe-Calc e acesso pela rede..."

    if [ -n "$SOCAT_PID" ]; then
        kill "$SOCAT_PID" 2>/dev/null || true
        wait "$SOCAT_PID" 2>/dev/null || true
    fi

    if [ -n "$PJECALC_PID" ]; then
        kill "$PJECALC_PID" 2>/dev/null || true
        wait "$PJECALC_PID" 2>/dev/null || true
    fi
}

trap encerrar EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

echo "=========================================="
echo "        PJe-Calc Cidadão - Ubuntu"
echo "=========================================="
echo "Diretório: $SCRIPT_DIR"
echo "Java: $JAVA_CMD"
echo ""

# Inicialização do servidor Java
"$JAVA_CMD" \
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

# Inicialização do acesso pela rede
if command -v socat >/dev/null 2>&1 && [ -n "$IP_LOCAL" ]; then

    socat \
      TCP-LISTEN:9258,bind="$IP_LOCAL",reuseaddr,fork \
      TCP:127.0.0.1:9257 &

    SOCAT_PID=$!

    # Confirma que o processo permaneceu ativo
    sleep 1

    if kill -0 "$SOCAT_PID" 2>/dev/null; then
        ACESSO_REDE=1
    else
        echo "Aviso: não foi possível iniciar o acesso pela rede."
        SOCAT_PID=""
        ACESSO_REDE=0
    fi
else
    ACESSO_REDE=0
    echo "Aviso: socat indisponível ou IP local não identificado."
fi

echo "Aguardando servidor PJe-Calc na porta 9257..."

ABERTO=0

while kill -0 "$PJECALC_PID" 2>/dev/null; do

    if [ "$ABERTO" -eq 0 ]; then

        if curl -s -I "$URL_PJECALC" 2>/dev/null |
           grep -Eq "HTTP/.* (200|302)"; then

            echo ""
            echo "=========================================="
            echo "       PJe-Calc iniciado com sucesso!"
            echo "=========================================="
            echo ""
            echo "Acesso neste computador:"
            echo "  $URL_PJECALC"
            echo ""

            if [ "$ACESSO_REDE" -eq 1 ]; then
                echo "Acesso pela rede local:"
                echo "  http://$IP_LOCAL:9258/pjecalc/pages/principal.jsf"
                echo ""
                echo "Utilize esse endereço no navegador"
                echo "do celular, tablet ou outro computador"
                echo "conectado à mesma rede."
            fi

            echo ""
            echo "Para encerrar, pressione Ctrl+C."
            echo "=========================================="

            sleep 2

            if ! pgrep -f "$URL_PJECALC" >/dev/null 2>&1; then
                firefox "$URL_PJECALC" &
            fi

            ABERTO=1
        fi
    fi

    sleep 2
done

wait "$PJECALC_PID" 2>/dev/null || true
