# Using official Python runtime base image
FROM python:3.10.5-alpine3.16

# Set the application directory
WORKDIR /app

# Install required dependencies
RUN apk add --no-cache postgresql-dev musl-dev gcc

# Install our requirements.txt
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# Copy our code from the current folder to /app inside the container
COPY . /app

# Expose the correct port for Gunicorn (8080)
EXPOSE 8080

# Define our command to be run when launching the container
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]

