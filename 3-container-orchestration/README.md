# Container orchestration

## What/Why?

Today an organization might have hundreds or thousands of containers. An amount that would be nearly impossible for teams to manage manually. This is where container orchestration comes in.

A container orchestration platform schedules and automates management like container deployment, networking, load balancing, scalability and availability.

* Provisioning
* Redundancy
* Health monitoring
* Resource allocation
* Scaling and load balancing
* Moving between physical hosts

## Kubernetes and Openshift

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