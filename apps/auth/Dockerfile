FROM node:20

WORKDIR /apps

COPY apps/auth ./apps/auth
RUN true
COPY .env ./.env
RUN true
COPY libs/firebase ./libs/firebase
RUN true
COPY libs/bcrypt ./libs/bcrypt
RUN true
COPY libs/guard ./libs/guard
RUN true
COPY libs/common ./libs/common
RUN true
COPY libs/schema ./libs/schema
RUN true
COPY libs/prisma ./libs/prisma
RUN true
COPY libs/common ./libs/common
RUN true
COPY .eslintignore .
RUN true
COPY .eslintrc.json .
RUN true
COPY .editorconfig .
RUN true
COPY .prettierrc .
RUN true
COPY .prettierignore .
RUN true
COPY jest.config.ts .
RUN true
COPY jest.config.ts .
RUN true
COPY google-services.json .

RUN true
COPY package.json .
RUN true
COPY tsconfig.base.json .
RUN true
COPY pnpm-lock.yaml .

RUN true
RUN sed -i '/"@nx\/cypress": "17.1.3",/d' package.json
RUN true
RUN sed -i '/"cypress": "^13.0.0",/d' package.json
RUN true
RUN npm install -g pnpm
RUN true
RUN pnpm install
RUN true
RUN true
RUN npx prisma generate --schema=./libs/schema/schema.prisma
RUN true
COPY nx.json .
RUN true

RUN npx nx run auth:build


RUN export GOOGLE_APPLICATION_CREDENTIALS=google-services.json
RUN export JWT_SECRET=auth-secret-1234

CMD ["node", "dist/apps/auth/main.js"]
