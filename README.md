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

🚨🚨**IMPORTANT** : 

Make sure to delete the node group , the cluster , the repository and the access key by the end of the project to avoid charges .

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

## Step3 : Deploy the application in a kubernetes cluster using EKS AWS service

Cool , so we have our appilcation image built , what do we do with it ?

Well naturally , push it !

 - We will use ECR service = Elastic Container Registry (it's like dockerHub but in aws )
 - We need to create a repository , and then push the image

To do that you can directly create a repository manually or you can use **boto3** which is certainly more fun 😁 \
you need to add the [ecr.py](https://github.com/HafssaRaoui/k8s-monitoring-app/blob/main/ecr.py)
- boto3 is a module used to create aws ressources by writting code
- Here we need an ECR client service
- Make the create_repository api call (Specify the name of your repository)

By the end , you should find the repository created in aws ECR
Follow the instructed commands in order to push the image into your repository \
Just run them all sequencely
![Screenshot from 2025-04-03 16-23-12](https://github.com/user-attachments/assets/3ecec65b-43a9-462b-b1ac-ebea66e63df7)

✅ Pushed the image ? Great work , Let's move on to the cluster creation .

- Head to EKS aws service
- Create a configured cluster
- Choose the vpc , the subnets (you will need to create EKS role + leave all other defaults and just next everything else)
- Add a node group (2 of t3 micro nodes should be sufficient)

Note that the creation of the cluster takes up to 10 minutes or a little more , so be patient 🧘

After we need to create the deployment and the service in our [eks.py](https://github.com/HafssaRaoui/k8s-monitoring-app/blob/main/eks.py)

First update kubernetes configuration from aws :
```
aws eks update-kubeconfig --name your-cluster-name
```

Browse to . ~/.kube to find the config \
- Okay , before we move on , we need to understand some basic concepts concerning Kubernetes API objects specifically : deployments, services
- A **deployment** : is an  object that manages a set of **Pods**(containers) to run an application workload, usually one that doesn't maintain state.
It is a controller that mangages the lifecycle of the pods ensuring the desired replicas of the application are always running and can be updated or restarted if needed .
- A **service** : is simply how we expose a network application that is running as one or more pods and make it accessible via an ip adress or load balancer DNS

In the [eks.py](https://github.com/HafssaRaoui/k8s-monitoring-app/blob/main/eks.py) file :
- first line consists on loading the configuration of the cluster = connect to the cluster
- Then we define the deployment (specifying the port 5000 and the **image uri**)
- We create the deployment \
  And same for the service \
  Once done , run the eks.py file and check the creation of the deployment and service using : ```kubectl get deployment -n default``` , ```kubectl get service -n default```



![Screenshot from 2025-04-03 16-55-39](https://github.com/user-attachments/assets/60aa11da-0493-4ff9-92a2-3c5114ff17ce)

Here it's not yet ready but you should see a 1/1

- We're almost done , we need to port forward the port 5000
  Why ?
Because **port forwarding** allows us to expose a specific port of a pod to the local system, so we can access the application without needing an external service or LoadBalancer.
Do that by the following command :
```
port forward svc/service-name 5000:5000
```
![Screenshot from 2025-04-03 17-01-49](https://github.com/user-attachments/assets/4732630e-1185-4178-b32c-9eaa87896e43)

Now the application should be accessible via http://localhost:5000/ \
🎉 And just like that we succeeded to deploy our cloud native app on a kubernetes cluster .
![Screenshot from 2025-04-03 17-02-58](https://github.com/user-attachments/assets/a84e4620-27b4-486b-998f-1b641ff165a4)

🚨🚨**IMPORTANT** : 

Make sure to delete the node group , the cluster , the repository and the access key by the end of the project to avoid charges .

