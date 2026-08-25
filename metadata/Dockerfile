FROM python:3.12-alpine

# 国内网络默认走阿里源;海外构建:docker compose build --build-arg USE_CN_MIRROR=0
ARG USE_CN_MIRROR=1
RUN if [ "$USE_CN_MIRROR" = "1" ]; then \
      pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/; \
    fi; \
    pip install --no-cache-dir flask
COPY internal_metadata.py /app/internal_metadata.py
WORKDIR /app
CMD ["python", "internal_metadata.py"]
