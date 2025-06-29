FROM python:3.10-bullseye
WORKDIR /
COPY www www
WORKDIR /www
EXPOSE 8000
ENTRYPOINT ["python"]
CMD ["-m", "http.server"]
