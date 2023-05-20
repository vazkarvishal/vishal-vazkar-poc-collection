FROM python:3.8-alpine

RUN mkdir app

WORKDIR /app

CMD pip install -r requirements.txt && uvicorn main:app --host "0.0.0.0" --reload