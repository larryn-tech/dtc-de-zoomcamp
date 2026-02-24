# Module 1: Containerization and Infrastructure as Code (IaC)

This week's module focuses on using Docker to create a pipeline for collecting and storing data in a database. I also explore using Terraform to build and manage infrastructure, using **AWS** as the cloud provider.

## 🐳 Docker
Docker packages applications and dependencies into **containers** that run reliably on any system. This ensures the environment is reproducible and scalable across development, testing, and production.

**Key Components:**
* **Image**: A read-only blueprint containing the code and dependencies.
* **Container**: A runnable, isolated instance of an image.
* **Dockerfile**: A script containing instructions to build an image.
* **Volumes**: Mechanisms for persisting data even after a container is deleted.
* **Docker Compose**: A tool for defining and running multi-container applications via a `.yaml` file.

**Key Commands:**
* `docker build -t <image_name> .`: Build an image from a Dockerfile.
* `docker images`: List all local images.
* `docker run -it --rm <image_name>`: Run an interactive container that deletes itself on exit.
* `docker run -v <host_path>:<container_path> <image_name>`: Mount a volume for data persistence.
* `docker ps -a`: List all containers (running and stopped).
* `docker stop <container_name>`: Stop a running container.
* `docker compose up`: Build and start all services defined in `compose.yaml`.
* `docker compose down`: Stop and remove all containers, networks, and volumes created by `docker compose up`.

## 🏗️ Terraform
Terraform is an **Infrastructure as Code (IaC)** tool that allows us to build, version, and manage cloud and on-premise resources using human-readable configuration files. It uses a declarative approach that allows users to define the desired final state of their infrastructure, rather than providing step-by-step instructions on how to achieve it. Much like Docker provides consistency for application environments, Terraform ensures consistent, scalable, and shareable infrastructure across teams.

**Key Components**:
* **Configuration files**: `.tf` files where infrastructure is declared.
* **State file**:  File (ex. `terraform.tfstate`) that keeps a persistent record of the infrastructure and maps real-world resources to your configuration file.
* **Providers**: Plugins (e.g., AWS, GCP) that allow Terraform to interact with specific APIs.

**Terraform Workflow**:
1. **Write**: Define resources (S3 buckets, EC2 instances) in `.tf` files.
2. **Plan**: Terraform compares the code to the current state and creates an execution plan.
3. **Apply**: Terraform executes the plan to reach the desired state.

**Key Commands:**
* `terraform init`: Initialize the directory and download provider plugins.
* `terraform plan`: Preview the changes before they are made.
* `terraform apply`: Provision the infrastructure.
* `terraform destroy`: Tear down all managed infrastructure.