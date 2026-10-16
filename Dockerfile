FROM node:24-bookworm-slim AS build

WORKDIR /app
ENV CI=true

RUN npm install -g pnpm@11.24.0

COPY . .
RUN pnpm install --frozen-lockfile

RUN pnpm exec vp pack \
    && pnpm exec vp -C packages/tdesign pack \
    && pnpm exec vp -C packages/shadcn pack \
    && pnpm exec vp -C packages/antd pack \
    && pnpm exec vp check \
    && pnpm exec vp test \
    && pnpm run demo:build

RUN test -s playground/dist/index.html

FROM nginx:stable-alpine
COPY --from=build /app/playground/dist/ /usr/share/nginx/html/
EXPOSE 80