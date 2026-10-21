# PJe-Calc Cidadão no Ubuntu

Instalador comunitário em Bash para instalar ou desinstalar o **PJe-Calc Cidadão 2.16.0** no Ubuntu, utilizando os arquivos de inicialização, ícone e atalhos fornecidos junto com este projeto.

> **Aviso:** este script não é um instalador oficial da Justiça do Trabalho. O pacote do PJe-Calc é baixado do endereço do TRT da 8ª Região indicado no script. Confira a origem dos arquivos antes de executar.

## Requisitos

- Ubuntu com acesso à internet e `sudo`;
- Gerenciador de pacotes `apt`;
- Disponibilidade dos pacotes `openjdk-8-jre`, `p7zip-full`, `curl`, `wget`, `firefox` e `firefox-l10n-pt-br` nos repositórios configurados;
- Ambiente gráfico para abrir a interface pelo Firefox.

O instalador usa o Java 8 para executar o PJe-Calc. A disponibilidade dos pacotes pode variar conforme a versão e os repositórios do Ubuntu.

## Arquivos do projeto

Mantenha estes cinco arquivos **na mesma pasta**:

```text
pjecalc-ubuntu/
├── instalar.sh
├── iniciar-pjecalc.sh
├── pjecalc.desktop
├── pjecalc.png
└── FirefoxPortable.exe
```

| Arquivo | Finalidade |
| --- | --- |
| `instalar.sh` | Menu de instalação e desinstalação |
| `iniciar-pjecalc.sh` | Inicia o serviço local do PJe-Calc e abre o navegador |
| `pjecalc.desktop` | Atalho para o menu e a área de trabalho |
| `pjecalc.png` | Ícone do aplicativo |
| `FirefoxPortable.exe` | **Script Bash**, apesar da extensão `.exe`, usado como substituto de `firefox.exe` para chamar o Firefox nativo |

O instalador do PJe-Calc (`pjecalc-2.16.0-instalador-x64.exe`) será baixado automaticamente, caso não exista na pasta do projeto. Se já estiver lá, será reutilizado.

## Instalar

Abra um terminal na pasta dos arquivos e execute:

```bash
chmod +x instalar.sh
./instalar.sh
```

Escolha **`1) Instalar`**. O script:

1. Confere os quatro arquivos auxiliares;
2. Instala as dependências pelo `apt`;
3. Baixa, se necessário, o instalador da versão 2.16.0;
4. Extrai a distribuição e instala em `/opt/pjecalc64`;
5. Copia o script de inicialização, o ícone e o wrapper do Firefox;
6. Cria atalhos no menu de aplicativos e na área de trabalho.

Se `/opt/pjecalc64` já existir, o script pedirá confirmação antes de substituí-lo. **A substituição apaga o conteúdo anterior desse diretório.** Faça backup de arquivos pessoais eventualmente armazenados nele.

## Abrir o PJe-Calc

Procure **PJe-Calc Cidadão** no menu de aplicativos ou utilize o atalho da área de trabalho.

Também é possível iniciar pelo terminal:

```bash
/opt/pjecalc64/iniciar-pjecalc.sh
```

O serviço local utiliza a porta **9257** e a interface é aberta em:

```text
http://localhost:9257/pjecalc/pages/principal.jsf
```

## Atalho da área de trabalho

O instalador tenta identificar a pasta configurada pelo Ubuntu usando `xdg-user-dir DESKTOP`, cria o arquivo `pjecalc.desktop` nela e o marca como confiável com `gio`, quando disponível.

Se o atalho não aparecer e sua pasta for `~/Área de Trabalho`, você pode copiá-lo manualmente:

```bash
cp ~/.local/share/applications/pjecalc.desktop "$HOME/Área de Trabalho/"
chmod +x "$HOME/Área de Trabalho/pjecalc.desktop"
gio set "$HOME/Área de Trabalho/pjecalc.desktop" metadata::trusted true
```

Para descobrir o diretório configurado no seu sistema:

```bash
xdg-user-dir DESKTOP
```

> Em algumas configurações do GNOME, a exibição de ícones na área de trabalho depende de uma extensão de desktop habilitada. Criar o arquivo `.desktop` não garante, por si só, que o GNOME o exibirá.

## Desinstalar

Na pasta do projeto, execute:

```bash
./instalar.sh
```

Escolha **`2) Desinstalar`** e confirme. O script remove:

- `/opt/pjecalc64`;
- `~/.local/share/applications/pjecalc.desktop`;
- `pjecalc.desktop` da pasta da área de trabalho identificada na execução.

**Atenção:** a desinstalação apaga todo o conteúdo de `/opt/pjecalc64`, inclusive dados pessoais que tenham sido salvos ali. Ela **não remove** Java, Firefox ou as demais dependências compartilhadas e **não apaga** o instalador `.exe` baixado na pasta do projeto.

Se o atalho tiver sido copiado manualmente para outra pasta, remova essa cópia separadamente.

## Observações técnicas

- O arquivo `FirefoxPortable.exe` fornecido neste projeto é um wrapper Bash que chama `/usr/bin/firefox`; não é o Firefox Portable para Windows.
- O instalador preserva o executável `firefox.exe` original extraído como `firefox.exe.bak`, quando aplicável, antes de instalar o wrapper.
- O script `iniciar-pjecalc.sh` contém parâmetros específicos de Java, codificação, fuso horário e integração de segurança. Revise-os antes de adaptar o projeto a outros ambientes.
- O instalador e o lançador foram preparados para esta estrutura de arquivos; não há garantia de compatibilidade com versões futuras do PJe-Calc.

## Licenciamento e responsabilidade

Este repositório contém scripts auxiliares de instalação. O PJe-Calc e seus componentes de terceiros permanecem sujeitos às condições de distribuição de seus respectivos titulares. O uso e as alterações deste instalador são de responsabilidade de quem o executa.
