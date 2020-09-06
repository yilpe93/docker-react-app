# Builder Stage : 빌드 파일들을 생성
FROM node:alpine as builder

WORKDIR "/usr/src/app"

COPY package.json ./

RUN npm install

COPY ./ ./

RUN npm run build

# Run Stage : Nginx를 가동하고 첫번째 단계에서 생성된 빌드 폴더의 팔일들을 웹 브라우저의 요청에 따라 제공
FROM nginx
# nginx port
EXPOSE 80
COPY --from=builder /usr/src/app/build /usr/share/nginx/html