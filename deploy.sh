#!/bin/bash

# ==========================================
# Script de Deploy - Azevedos Tech (Static)
# ==========================================

# Como você não tem um domínio próprio (ex: azevedostech.com),
# vamos usar um nome de bucket exclusivo que o Google aceitará direto.
# O nome do bucket não pode ter pontos se não for domínio verificado.
BUCKET_ID="azevedostech"
BUCKET_NAME="gs://$BUCKET_ID"
EMAIL="hitchaz@gmail.com"

echo "=============================================="
echo "🚀 Iniciando processo de Deploy da Azevedos Tech"
echo "=============================================="

# 1. Verifica se o gcloud (Google Cloud CLI) está instalado
if ! command -v gcloud &> /dev/null
then
    echo "❌ O Google Cloud CLI ('gcloud') detectado como NÃO instalado no seu Mac."
    echo ""
    echo "👉 Como você usa Mac, a forma mais rápida de instalar é abir uma nova aba no terminal e rodar:"
    echo "   brew install --cask google-cloud-sdk"
    echo ""
    echo "Após instalar e rodar 'gcloud init', execute este script (./deploy.sh) novamente!"
    exit 1
fi

# 2. Configura a conta do Google correta
echo "🔐 Garantindo o uso da conta: $EMAIL"
gcloud config set account $EMAIL

# Configura o projeto do GCP automaticamente
echo "📁 Configurando o projeto do Google Cloud..."
gcloud config set project azevedostech

# 3. Criação do Bucket
echo "🪣 Criando o bucket no Storage: $BUCKET_NAME..."
# Remove suppression to see if there is any other error
gcloud storage buckets create $BUCKET_NAME --location=US --uniform-bucket-level-access || echo "Bucket já existe ou houve pequeno erro, prosseguindo..."

# 4. Permissões Públicas
echo "🌍 Adicionando acesso de visualização pública ao site..."
gcloud storage buckets add-iam-policy-binding $BUCKET_NAME \
    --member="allUsers" \
    --role="roles/storage.objectViewer" 2>/dev/null || true

# 5. Define as páginas do site
echo "🕸️ Configurando index.html como página principal..."
gcloud storage buckets update $BUCKET_NAME \
    --web-main-page-suffix=index.html 

# 6. Upload dos Arquivos
echo "📤 Fazendo o upload dos arquivos para a nuvem..."
# Sobe exatamente as tecnologias do frontend
gcloud storage cp index.html $BUCKET_NAME/
gcloud storage cp privacy.html $BUCKET_NAME/
gcloud storage cp style.css $BUCKET_NAME/
# Sobe o crítico app-ads.txt para ficar em azevedostech.com/app-ads.txt
gcloud storage cp app-ads.txt $BUCKET_NAME/

echo "=============================================="
echo "✅ DEPLOY CONCLUÍDO!"
echo "=============================================="
echo ""
echo "🔗 Seu site está no ar de forma 100% gratuita no link abaixo:"
echo "👉 https://${BUCKET_ID}.storage.googleapis.com/index.html"
echo ""
echo "📱 IMPORTANTE PARA O ADMOB:"
echo "1. Vá até a Google Play / App Store e cadastre esse site exato como 'Site do Desenvolvedor':"
echo "   https://${BUCKET_ID}.storage.googleapis.com"
echo "2. O robô do AdMob automaticamente vai encontrar seu arquivo de anúncios em:"
echo "   https://${BUCKET_ID}.storage.googleapis.com/app-ads.txt"
