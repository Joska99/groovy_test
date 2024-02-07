# Base image, minimal python
FROM python:slim

# Copy requirement for Cache
COPY ./app/requirements.txt /weather_app/requirements.txt
RUN pip install -r /weather_app/requirements.txt 

# Create ans enter to Working Directory
WORKDIR /weather_app

# Coppe entire files to Start cache from there and remove requirements
COPY ./app /weather_app/
RUN rm -f requirements.txt

# RECHECK USER IN PYTHON IMG
# Add user for security
RUN useradd -ms /bin/bash JOSKA
USER JOSKA

# Dockkumentation 
EXPOSE 5000

# RECHECK THIS THING
# ENTRPOINT cannot be overiten
# Use CMD as argument for ENTRPOINT
ENTRYPOINT [ "python" ]
CMD ["front.py"]