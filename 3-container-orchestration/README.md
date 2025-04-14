# Container orchestration

## What/Why?

Today an organization might have hundreds or thousands of containers. An amount that would be nearly impossible for teams to manage manually. 

**Problem** : as the number of containers managed by an organization grows, the work of manually starting them rises exponentially along with the need to quickly respond to external demands.

**Enterprise needs**:

* Easy communication between a large number of services
* Resources limits on applications regardless of the number fo containers running them
* To respond to application usage spikes to increase or decrease running containers
* Reacs to service deterioration with health checks
* Gradual roll out fo a new release to a set of users

This is where **container orchestration** comes in.

## Kubernetes and Openshift

**Kubernetes is an orchestration service that simplifies the deployment, management, and scaling of containerized applications.**

Kubernetes is an orchestration service that simplifies the deployment, management, and scaling of containerized applications, the smallest unit if kunernetes is a pod that consist of one or more containers.

Kubernetes features of top of a container infra:

**Service discovery and loading balancing** : communication by a single DNS entry to each set of container, permits the load balancing across the pool of container.
**Horizontal scaling** : Applications can scale up and down manually or automatically
**Self-Healing**: user-defined health checks to monitor containers to restart in case of failure
**Automated rollout and rollback** : roll updates out to application containers, if something goes wrong kubernetes can rollback to previous integration of the deployment
**Secrets and configuration management** : can manage the config settings of application without rebuilding container
**Operators** : use API to update the cluster state reacting to change in the app state

Red Hat OpenShift Container Plataform (RHOCP) is a set of modular components and services build on top of Kubernetes, adds the capabilities to provide PaaS platform.

OpenShift features to kubernetes cluster :

**Integrated developer workflow** : integrates a build in container registry, CI/CD pipeline and S2I, a tool to build artifacts from source repositories to container image
*Routes* : expose service to the outside world
**Metrics and logging** : Metric service and aggregated logging
**Unified UI** : UI to manage the different capabilities


## Kubernetes Arhitecture

A Kubernetes cluster consists of a control plane plus a set of worker machines, called nodes, that run containerized applications. Every cluster needs at least one worker node in order to run Pods.

![Kubernetes cluster arhitecture](../_img/kubernetes-cluster-architecture.svg "Kubernetes cluster arhitecture")

Kubernetes objects are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of your cluster.

Pods are the smallest deployable units of computing that you can create and manage in Kubernetes.

A Pod (as in a pod of whales or pea pod) is a group of one or more containers, with shared storage and network resources, and a specification for how to run the containers.

There are many other object such as:

*	**Deployments** – Manage stateless applications and ensure the desired number of Pods are running.
*	**ReplicaSets** – Ensure a specified number of identical Pods are maintained.
*	**StatefulSets** – Manage stateful applications that require persistent identity and storage.
*	**DaemonSets** – Ensure a copy of a Pod runs on all (or some) nodes in the cluster.
*	**Jobs** – Create Pods to run a task to completion.
*	**CronJobs** – Run Jobs on a scheduled time (like cron).
*	**Services** – Provide stable networking and load balancing for Pods.
*	**Ingress** – Manage external access to Services, usually HTTP.
*	**ConfigMaps** – Provide configuration data in key-value pairs.
*	**Secrets** – Store sensitive data such as passwords or tokens.
*	**Volumes** – Provide persistent or shared storage to Pods.
*	**Namespaces** – Support multiple virtual clusters within the same physical cluster.


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-hello-app
  labels:
    app: go-hello-app
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1           # Allows 1 extra pod during update
      maxUnavailable: 0     # Ensures no pods are taken down before new ones are ready
  selector:
    matchLabels:
      app: go-hello-app
  template:
    metadata:
      labels:
        app: go-hello-app
    spec:
      containers:
        - name: go-hello-app
          image: docker.io/ciucurdaniel/go-hello-app:latest
          ports:
            - containerPort: 8080
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 2
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 2
            failureThreshold: 3
```


```yaml
apiVersion: v1
kind: Service
metadata:
  name: go-hello-app
  labels:
    app: go-hello-app
spec:
  selector:
    app: go-hello-app
  ports:
    - name: http
      port: 80
      targetPort: 8080
  type: ClusterIP
```

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: go-hello-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: go-hello-app
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```