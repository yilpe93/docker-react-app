## Docker React App

### docker build

```bash
# dev
$ docker build -f Dockerfile.dev ./

# real
$ docker build -f Dockerfile ./
```

### docker run

```bash
# COPY
$ docker run -it -p 3000:3000 yilpe/docker-react-app

# Volume
$ docker run -it -p 3000:3000 -v /usr/src/app/node_modules -v $(pwd):/usr/src/app yilpe/docker-react-app
```

### docker compose

```yml
# docker-compose.yml

# 도커 컴포즈의 버전
version: "3"

# 이곳에 실행하려는 컨테이너들을 정의
services:
  # 컨테이너 이름
  react:
    # 현 디렉토리에 있는 Dockerfile 사용
    build:
      # 도커 이미지를 구성하기 위한 파일과 폴더들이 있는 위치
      context: .
      # 도커 파일 어떤 것인지 지정
      dockerfile: Dockerfile.dev
    # 포트 맵핑, 로컬 포트 : 컨테이너 포트
    ports:
      - "3000:3000"
    # 로컬 머신에 있는 파일들 맵핑
    volumes:
      - /usr/src/app/node_modules
      - ./:/usr/src/app
    # 리액트 앱을 끌때 필요
    stdin_open: true
```

---

## Nginx

```dockerfile
# Builder Stage : 빌드 파일들을 생성
FROM node:alpine as builder

WORKDIR "/usr/src/app"

COPY package.json ./

RUN npm install

COPY ./ ./

# CMD [ "npm", "run", "build" ]
RUN npm run build

# Run Stage : Nginx를 가동하고 첫번째 단계에서 생성된 빌드 폴더의 팔일들을 웹 브라우저의 요청에 따라 제공
FROM nginx

COPY --from=builder /usr/src/app/Tbuild /usr/share/nginx/html
```

> --from=builder : 다른 Stage에 있는 파일을 복사할때 다른 Stage 이름을 명시

> /usr/src/app/build /usr/share/nginx/html : builder stage에서 생성된 파일들은 `/usr/src/app/build`에 들어가게 되며 그곳에 저장된 파일들을 `/usr/share/nginx/html`로 복사하여 nginx가 웹 브라우저의 http 요청이 올때 마다 알맞은 파일을 전해 줄 수 있게 만든다.

```bash
# Docker Image Build
$ docker build

# Docker Image Run : nginx의 기본 포트는 80
docker run -p 8080:80
```

---

## Travis CI란?

Travis CI는 Github에서 진행되는 오픈소스 프로젝트를 위한 지속적인 통합(Continuous Integration) 서비스이다. Travis CI를 이용하면 Github repository에 있는 프로젝트를 특정 이벤트에 따라 자동으로 테스트, 빌드하거나 배포할 수 있다. Private repository는 유료로 일정 금액을 지불하고 사용할 수 있다.

> 로컬 Git -> Github -> Travis CI -> AWS

1. 로컬 Git에 있는 소스를 Github 저장소에 Push
2. Github master 저장소에 소스가 Push가 되면 Travis CI에게 소스가 Push 되었다고 전달
3. Travis CI는 업데이트 된 소스를 Github에서 가지고 온다.
4. Github에서 가져온 소스의 테스트 코드를 실행
5. 테스트 코드 실행 후 테스트가 성공하면 AWS같은 호스팅 사이트로 보내서 배포

### .travis.yml 셋팅

```yml
# .travis.yml

# 관리자 권한갖기
sudo: required

# 언어(플랫폼) 선택
language:

# 도커 환경 구성
services:

# 스크립트를 실행할 수 있는 환경
before_install:

# 실행할 스크립트(테스트 실행)
script:

# 배포 자동화
deploy:
  # 외부 서비스 표시(s3, elastic beanstalk, firebase 등)
  provider:
  # 현재 사용하고 있는 AWS의 서비스가 위치하고 있는 물리적 장소
  region:
  # 생성된 어플리케이션 이름
  app:
  env:
  # 해당 elasticbeanstalk을 위한 s3 버켓 이름
  bucket_name:
  # app과 같이 작성
  bucket_path:

# 테스트 성공 후 할일
after_success:
```

1. 도커 환경에서 리액트앱을 실행하고있으니 Travis CI에서도 도커환경 구성
2. 구성된 도커 환경에서 Dockerfile.dev를 이용해서 도커 이미지 생성
3. 어떻게 Test를 수행할 것인지 설정
4. 어떻게 AWS에 소스코드를 배포할 것인지 설정

---

## AWS 서비스

### EC2(Elastic Compute Cloud) 란?

Amazon Elastic Compute Cloud(Amazon EC2)는 Amazon WebServices(AWS) 클라우드에서 확장식 컴퓨팅을 제공한다. Amazon EC2를 사용하면 하드웨어에 선튜자할 필요가 없어 더 빠르게 애플리케이션을 개발하고 배포할 수 있다. Amazon EC2를 통해 원하는 만큼 가상 서버를 구축하고 보안 밑 네트워크 구성과 스토리지 관리가 가능하다. 또한, 요구사항이나 갑작스러운 인기 증대 등 변동 사항에 따라 신속하게 규모를 확장하거나 축소할 수 있어 서버 트래픽 예측 필요성이 줄어든다.

### EB(Elastic BeanStalk) 란?

AWS Elastic Beanstalk는 Apache, Nginx 같은 서버에서 Java, NET, PHP, Node.js, Python, Ruby,Go 및 `Docker`와 함께 개발된 웹 응용 프로그램 및 서비스를 배포하고 확장하기 쉬운 서비스이다.

## Secret, Access API Key 받는 순서

1. IAM USER 생성

### IAM(Identity and Access Management) 란?

AWS 리소스에 대한 엑세스를 안전하게 제어할 수 있는 웹 서비스이다. IAM을 사용하여 리소스를 사용하도록 인증(로그인) 및 권한 부여된 대상을 제어한다.

> Dashboard -> IAM 검색 -> 사용자 클릭 -> 사용자 추가 클릭

- 직접 API키를 Travis yml 파일에 적으면 노출이 되기 떄문에 다른곳에 적고 그것을 가져워 사용한다.

- Travis 웹사이트 해당 저장소 대쉬보드 사용

- 설정 -> Settings -> Environment Variables에 IAM에서 생성한 엑세스 KEY / ID를 각각 VALUE에 담아 추가

  위와 같이 추가하면 .travis.yml에서 `${설정한 네임}`으로써 travis 만의 환경변수로 사용하능하다.

  ```yml
  # .travis.yml

  # ...

  access_key_id: $AWS_ACCESS_KEY
  secret_access_key: $AWS_SECRET_ACCESS_KEY
  ```

---

[Load Balancer란?](https://nesoy.github.io/articles/2018-06/Load-Balancer)
[서버 아키텍쳐 용어 정리](https://www.slideshare.net/sunnykwak90/scale-up-and-scale-out)
