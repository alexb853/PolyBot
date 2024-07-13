# Jenkins, Containers & Webservers project

## Description
Welcome to our project! we will show you how to take a Python application and a static website running on Nginx, and containerize them using Docker.then we will deploy them using Docker Compose, which will enable us to run our app and website in containers. Additionally, we will create a Jenkinsfile to enable Continuous Integration and Continuous Deployment (CI/CD) for our app.

## Components
The project consists of the following components:

* Jenkins: Automates the build, test, and deployment process.
* Docker Compose: Manages multi-container Docker applications.
* Private Docker Hub Registry: Stores and manages Docker images.
* Web Servers: Hosts the application and the website.
* Nexus: Manages build artifacts and Docker images.

## Prerequisites
Before you begin, ensure you have the following installed:

* Docker
* Docker Compose
* Jenkins
* Pylint
* Snyk
* Nexus

## Setup Instructions
1. Clone the Repository
2. Ensure your docker-compose.yml is configured correctly
3. Set Up Jenkins

* Install Jenkins on your machine or server.
* Install necessary Jenkins plugins: Docker, Docker Pipeline, Warnings Next Generation, etc.
* Configure Jenkins to use your private Docker registry credentials.

4. Integrate Pylint in Jenkins

* Install Pylint on your Jenkins server.
* Configure the Warnings Next Generation Plugin to parse Pylint reports.

5. Set Up Snyk for Security Testing

* Create an account on Snyk.
* Install the Snyk CLI.
* Configure your Jenkins pipeline to include Snyk security tests.

6. Integrate Nexus
* Install Nexus: Follow the Nexus installation guide for your platform.
* Configure Nexus: Set up Nexus to manage your Docker images and build artifacts. Create a Docker registry and repository in Nexus.
* Integrate Nexus with Jenkins: Add Nexus credentials to Jenkins and configure your Jenkins pipeline to push Docker images and artifacts to Nexus.


