# use the official base image
FROM python:3.9-slim-buster

#setting up our working directory
WORKDIR /app

# installing dependencies in the container
COPY requirements.txt .


RUN pip3 install --no-cache-dir -r requirements.txt

#copy the src code
COPY . .

# env variable , to access Flask from outside the container
ENV FLASK_RUN_HOST=0.0.0.0

#we are only documenting , we still need to map the real port
EXPOSE 5000

#run the flask app
CMD [ "flask","run" ]
