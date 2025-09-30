# Use a small base that supports arm/amd64 (multi-arch official images)
FROM python:3.11-slim

WORKDIR /app
COPY app.py /app/

EXPOSE 8080
CMD ["python", "app.py"]
