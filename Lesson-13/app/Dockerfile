# Use a lightweight Python image
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Copy application files to the container
COPY . .

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set environment variables (these can also be overridden at runtime)
ENV FLASK_APP=app.py

# Run the application
CMD ["python", "app.py"]