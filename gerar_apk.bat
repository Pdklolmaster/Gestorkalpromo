@echo off
REM ╔══════════════════════════════════════════════════════════════╗
REM ║  SCRIPT: Gerar APK do Gestor 50/30/20                       ║
REM ║  Autor: Desenvolvido automaticamente                        ║
REM ║  Data: Janeiro 2024                                         ║
REM ╚══════════════════════════════════════════════════════════════╝

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║  Gestor 50/30/20 - Gerador de APK                           ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Verificar se Flutter está instalado
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERRO: Flutter não está instalado ou não está no PATH
    echo.
    echo Siga as instruções em: GERAR_APK.md
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter detectado
flutter --version
echo.

REM Entrar no diretório do projeto
cd /d "%~dp0"
echo 📁 Diretório do projeto: %CD%
echo.

REM Passo 1: Limpar build anterior
echo [1/5] 🧹 Limpando build anterior...
flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Erro ao limpar
    pause
    exit /b 1
)
echo ✅ Build anterior removido
echo.

REM Passo 2: Atualizar dependências
echo [2/5] 📦 Baixando dependências...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Erro ao baixar dependências
    pause
    exit /b 1
)
echo ✅ Dependências baixadas
echo.

REM Passo 3: Gerar código Hive
echo [3/5] 🔨 Gerando código Hive...
flutter pub run build_runner build
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Erro ao gerar código
    pause
    exit /b 1
)
echo ✅ Código Hive gerado
echo.

REM Passo 4: Build APK Release
echo [4/5] 🏗️  Compilando APK (isso pode levar 5-15 minutos)...
echo.
flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Erro ao compilar APK
    pause
    exit /b 1
)
echo ✅ APK compilado com sucesso!
echo.

REM Passo 5: Verificar e informar localização do APK
echo [5/5] 📍 Localizando APK...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo.
    echo ╔══════════════════════════════════════════════════════════════╗
    echo ║  ✨ APK GERADO COM SUCESSO! ✨                             ║
    echo ╚══════════════════════════════════════════════════════════════╝
    echo.
    echo 📱 Arquivo: app-release.apk
    echo 📁 Localização: %CD%\build\app\outputs\flutter-apk\
    echo.
    echo Como usar:
    echo ──────────────────────────────────────────────────────────────
    echo 1. Copie o arquivo para seu dispositivo Android
    echo 2. Abra o gerenciador de arquivos no dispositivo
    echo 3. Localize o arquivo app-release.apk
    echo 4. Toque para instalar
    echo.
    echo Ou instale via USB:
    echo ──────────────────────────────────────────────────────────────
    echo 1. Conecte o dispositivo via USB
    echo 2. Execute: flutter install
    echo.
    pause
) else (
    echo ❌ APK não foi encontrado no local esperado
    echo Tente novamente ou consulte GERAR_APK.md
    pause
    exit /b 1
)
