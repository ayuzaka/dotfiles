# Setup Python on Docker

`Dockerfile`

```docker
FROM python:3

WORKDIR /usr/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
```

`requirements.txt` に `pip` でインストールしたいライブラリを記載する

`docker-compose.yml`

```yaml
version: '3'
services:
  app:
    container_name: my-python
    build: .
    tty: true
    volumes:
      - ${PWD}/src:/usr/app/src
    ports:
      - "80:80"
```

```sh
.
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── src
    └── main.py
```
