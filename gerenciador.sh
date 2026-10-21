#!/usr/bin/env bash
set -Eeuo pipefail
BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST=/opt/pjecalc64
DESKTOP="$HOME/.local/share/applications/pjecalc.desktop"
INSTALLER="$BASE/pjecalc-2.16.0-instalador-x64.exe"
URL='https://www.trt8.jus.br/sites/portal/files/roles/pje-calc/pjecalc-2.16.0-instalador-x64.exe'
TEMP=''
cleanup() { if [[ -n "$TEMP" && -d "$TEMP" ]]; then rm -rf -- "$TEMP"; fi; }
trap cleanup EXIT

instalar() {
  for f in iniciar-pjecalc.sh pjecalc.desktop pjecalc.png FirefoxPortable.exe; do
    [[ -f "$BASE/$f" ]] || { echo "Arquivo ausente: $BASE/$f" >&2; return 1; }
  done
  if [[ -e "$DEST" ]]; then
    echo "Já existe uma instalação em $DEST."
    read -r -p 'Substituir a instalação existente? [s/N] ' confirma
    [[ "$confirma" =~ ^[sS]$ ]] || return 0
  fi
  sudo apt update
  sudo apt install -y openjdk-8-jre p7zip-full curl wget firefox firefox-l10n-pt-br
  if [[ ! -f "$INSTALLER" ]]; then
    wget -O "$INSTALLER.part" "$URL" || { rm -f "$INSTALLER.part"; return 1; }
    mv -- "$INSTALLER.part" "$INSTALLER"
  fi
  TEMP="$(mktemp -d)"
  7z x -y "$INSTALLER" "-o$TEMP" >/dev/null
  SOURCE="$(find "$TEMP" -type f -path '*/bin/pjecalc.jar' -printf '%h\n' -quit)"
  [[ -n "$SOURCE" ]] || { echo 'Não foi encontrado bin/pjecalc.jar na extração.' >&2; return 1; }
  SOURCE="$(dirname -- "$SOURCE")"
  [[ -d "$SOURCE/navegador/windows" ]] || { echo 'Estrutura navegador/windows não encontrada.' >&2; return 1; }
  sudo rm -rf -- "$DEST"
  sudo mkdir -p "$DEST"
  sudo cp -a "$SOURCE/." "$DEST/"
  sudo install -m 755 "$BASE/iniciar-pjecalc.sh" "$DEST/iniciar-pjecalc.sh"
  sudo install -m 644 "$BASE/pjecalc.png" "$DEST/pjecalc.png"
  if [[ -e "$DEST/navegador/windows/firefox.exe" && ! -e "$DEST/navegador/windows/firefox.exe.bak" ]]; then
    sudo mv "$DEST/navegador/windows/firefox.exe" "$DEST/navegador/windows/firefox.exe.bak"
  fi
  sudo install -m 755 "$BASE/FirefoxPortable.exe" "$DEST/navegador/windows/firefox.exe"
  sudo chown -R "$(id -u):$(id -g)" "$DEST"
  mkdir -p "$(dirname "$DESKTOP")"
  install -m 755 "$BASE/pjecalc.desktop" "$DESKTOP"
  update-desktop-database "$(dirname "$DESKTOP")" 2>/dev/null || true
  echo 'Instalação concluída.'
}

desinstalar() {
  echo "Serão removidos $DEST e $DESKTOP."
  echo 'Arquivos de dados eventualmente salvos dentro do diretório também serão apagados.'
  read -r -p 'Confirmar desinstalação? [s/N] ' confirma
  [[ "$confirma" =~ ^[sS]$ ]] || { echo 'Cancelado.'; return 0; }
  if [[ -d "$DEST" ]]; then sudo rm -rf -- "$DEST"; fi
  rm -f -- "$DESKTOP"
  update-desktop-database "$(dirname "$DESKTOP")" 2>/dev/null || true
  echo 'Desinstalação concluída.'
}

printf '\n=== PJe-Calc Cidadão - Ubuntu ===\n1) Instalar\n2) Desinstalar\n0) Sair\n'
read -r -p 'Escolha uma opção: ' opcao
case "$opcao" in
  1) instalar ;;
  2) desinstalar ;;
  0) echo 'Encerrado.' ;;
  *) echo 'Opção inválida.' >&2; exit 1 ;;
esac
