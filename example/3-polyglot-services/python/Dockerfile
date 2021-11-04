FROM python:3.9.7-slim as build

RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential gcc

COPY example/3-polyglot-services/python/ .
RUN pip install --user -r requirements.txt

ENTRYPOINT ["python", "app.py"]
