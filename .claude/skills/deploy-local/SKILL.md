---
name: deploy-local
description: Build and deploy the application to local Kubernetes. Use when asked to deploy, build Docker image, or manage K8s resources.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

Build and deploy the demo application to local Kubernetes:

## Steps

1. **Build the application**:
   ```bash
   ./mvnw -B package -DskipTests
   ```

2. **Build Docker image**:
   ```bash
   docker build -t demo-api:latest .
   ```

3. **Deploy to Kubernetes**:
   ```bash
   kubectl apply -f k8s/
   kubectl rollout status deployment/demo-api --timeout=120s
   ```

4. **Verify**:
   ```bash
   kubectl get pods -l app=demo-api
   kubectl port-forward svc/demo-api 8080:8080 &
   curl -s http://localhost:8080/actuator/health | jq .
   ```

5. **Show status**:
   - `kubectl get all -l app=demo-api`
   - Application URL: http://localhost:8080
