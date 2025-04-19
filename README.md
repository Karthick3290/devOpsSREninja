# devOpsSREninja

Full-Stack Learning & Observability Playground

This repository is a personal space to document and manage my learnings across various tools and technologies, starting with a basic Flask application, and gradually evolving into a full-stack system with strong monitoring and observability practices.

Goals

Build and scale a basic Flask app.

Apply DevOps/SRE practices around deployment and infrastructure.

Set up complete observability (monitoring, logging, tracing).

Capture and share key learnings along the way.


Stack (Phase 1)

Backend: [Flask (Python)]

Infrastructure: Docker, Kubernetes (EKS), Terraform

CI/CD: GitHub Actions (planned)

Monitoring: Prometheus + Grafana (planned)

Logging: Fluent Bit + Elasticsearch (planned)

Tracing: OpenTelemetry or Jaeger (planned)


Folder Structure

/flask-app       - Flask application code
/infrastructure  - Dockerfiles, Terraform, K8s manifests
/observability   - Dashboards, logging, tracing setup
/docs            - Learnings, setup guides, architecture decisions

Getting Started

1. Clone the repo


2. Navigate to flask-app


3. Set up a virtual environment and install dependencies


4. Run the Flask app locally



cd flask-app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py

Roadmap

[ ] Set up Flask app

[ ] Containerize with Docker

[ ] Deploy to Kubernetes (EKS)

[ ] Set up Prometheus + Grafana

[ ] Add logging and tracing

[ ] Document architecture and learnings