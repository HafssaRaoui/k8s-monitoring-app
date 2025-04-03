# ☸️ Deployment of a Cloud Native Monitoring App on Kubernetes
This project demonstrates how to deploy a simple Flask application on a Kubernetes cluster to monitor the CPU and memory utilization of the container running the application.

Initially the application shows the CPU and memory utilization percentage used by the system. \
Once containerized, it measures the resource usage inside the container, not the underlying system.
### 📢 A little heat up before we start
In the following I will go through the different steps by I which I completed the project  \
Once read ...\
Get yourself to work  !

### 🤔💭 So what do you need to complete this project
- python3 
- aws account
- programmatic access to aws cli 
- docker
- kubectl
- your favorite code editor (No arguing needed it should be VScode )

### How to enable programmatic access to aws cli from your machine :
- Access security credentials section in your aws account
- Manually create your access key and download the secret key 
  ![image](https://github.com/user-attachments/assets/604742ac-16e7-42fb-8d2f-d3ef699abdab)
- Next , in your terminal configure the aws cli using the command :

```
aws configure
```
- Provide your key credentials \
  And that's it ✅

### 🔍 Overview of the project workflow :
- Code the monitoring app
- Dockerize the Application  =  write the Dockerfile + build + run + test app accessibility
- Deploy the application on a kubernetes cluster using python kubernetes client

## Step1 : Setting up the application source code

This step won't take much time , the src code is already available on the repository \
The main application code is found in [app.py](https://github.com/HafssaRaoui/k8s-monitoring-app/blob/main/app.py)  .\
You will notice that we used the module **psutils** which is a python library for retrieving information on running processes and system utilization (CPU, memory, disks, network ...)

⚠️ All the required modules a listed in the [requirements.txt](https://github.com/HafssaRaoui/k8s-monitoring-app/blob/main/requirements.txt)
To install all requirements at once run : 
```
pip3 install -r requirements.txt
```
😁 After that hopefully you will say goodbye to  the dependencies headache . (If not try  upgrading pip)

- On linux OS you might face an issue about python **external package management** , which means you are not allowed to change tha packages outside of the **/usr/lib/python3.X directory** \
To fix that , browse to /usr/lib/python3.X , remove the EXTERNALLY-MANAGED file or rename it to  EXTERNALLY-MANAGED.back

- You will notice that the index function returns the template [index.html](https://github.com/HafssaRaoui/k8s-monitoring-app/blob/main/templates/index.html) so make sure to add it too .

- Once done , run the application using :
```
python3 app.py
```
Browse to the displayed url , typically Flask runs on http://localhost:5000/
You should see something like this : 
![Screenshot from 2025-04-03 12-09-26](https://github.com/user-attachments/assets/daf16644-4b98-458c-8883-8d95c48159ce) \
Try to refresh the browser , the values will change since the measurement is done on real time

## Step2 : Dockerize the application

What we will do is build the image of our application , and test its accessibility as a container .

Speaking of dockerizing , we need first of all a [Dockerfile](https://github.com/HafssaRaoui/k8s-monitoring-app/blob/main/Dockerfile) \
It is a classical Dockerfile :

- Choosing our **base image** , the official python3.9:slim-buster image
- Setting up our **work directory**
- Ensuring the installation of the required **dependencies** , by copying requirements.txt into the work directory and running the pip3 install command
- Creating an **environment variable** to allow accessing the app from outside the container , because on default Flask only listens locally
- Exposing the port 5000
- Finally **running the app**

Next , we need to build the image using :
```
docker build -t your-image-name .
```
Here the '.' refers to the only Dockerfile we have in the terminal directory

Once done , inspect your docker images using :
```
docker images
```
Run a container of your app image , and bind it to  the actual port 5000 of your machine :

```
docker run -p 5000:5000 image-id
```
If everything is cool you will get access to your application on http://localhost:5000/ 
![Screenshot from 2025-04-03 12-50-08](https://github.com/user-attachments/assets/e25a026c-7314-40d3-99e9-c7229555ea52)

## Step3 : Deploy the applciation in a kubernetes cluster using EKS AWS service

Cool , so we have our appilcation image built , what do we do with it

Well naturally , push it !

 - We will use ECR service = Elastic Container Registry (it's like dockerHub but in aws )
 - We need to create a repository , and then push the image

To do that you can directly create a repository manually or you can use **boto3** which is certainly more fun 😁

