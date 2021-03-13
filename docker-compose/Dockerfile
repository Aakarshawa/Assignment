# Pull the latest version of the Python container.
FROM python:latest
# Add the requirements.txt file to the image.
ADD requirements.txt /app/requirements.txt
# Set the working directory to /app/.
WORKDIR /app/
# Install Python dependencies.
RUN pip install -r requirements.txt
# Create an unprivileged user for running our Python code.
RUN adduser — disabled-password — gecos ‘’ app
