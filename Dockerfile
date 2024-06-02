# syntax=docker/dockerfile:1
FROM python:3.10-alpine
WORKDIR /app
COPY . /app
RUN pip install  --no-cache-dir -r requirements.txt
EXPOSE 5000
ENV FLASK_APP=app.py
CMD ["python", "app.py"]

