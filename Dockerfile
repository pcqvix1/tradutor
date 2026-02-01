FROM node:20-alpine AS builder

# Configura diretório de trabalho
WORKDIR /app

# Instala dependências
COPY package*.json ./
RUN npm ci

# Copia código fonte e faz o build
COPY . .
RUN npm run build

# --- Estágio Final ---
FROM node:20-alpine

WORKDIR /app

# Copia apenas os arquivos necessários para rodar (menor tamanho, mais segurança)
COPY package*.json ./
RUN npm ci --omit=dev

# Copia o build do estágio anterior
COPY --from=builder /app/dist ./dist

# Copia arquivos do servidor e assets necessários
COPY server.js .
COPY masqr.js .
COPY Checkfailed.html .
COPY placeholder.svg .

# Define variáveis de ambiente padrão
ENV PORT=8000
ENV NODE_ENV=production

# Expõe a porta
EXPOSE 8000

# Comando de inicialização
CMD ["npm", "start"]