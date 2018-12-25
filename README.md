**Highly Scalable Enterprise Grade Elasticsearch (ELK stake) Deployment on Kubernetes Cluster**

This repository provides Elasticsearch deployment artifacts for Kubernetes platform. The images support XPACK, Security and Machine Learning modules also.

Assuming you have Kubernetes 1.13+ installed, with 6 nodes. The node names we have are :

- r-node-1 &nbsp;&nbsp;&nbsp;     K8s master
- r-node-2  &nbsp;&nbsp;&nbsp;    Worker
- r-node-3  &nbsp;&nbsp;&nbsp;    Worker
- r-node-4  &nbsp;&nbsp;&nbsp;    Worker
- r-node-5  &nbsp;&nbsp;&nbsp;    Worker
- r-node-6  &nbsp;&nbsp;&nbsp;    Worker
- r-node-7  &nbsp;&nbsp;&nbsp;    Worker

If you do not have shared storage across worker nodes, then you need to tie up specific roles of the ELK components to specific nodes. But if you have shared storage, then you are quite free.

First let's create the namespace named es:

>kubectl create ns es

Let's label the nodes to specific roles. The roles we want are: 

-   es-data: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;    data node
-   es-master: &nbsp;&nbsp;  master node
-   es-ingest: &nbsp;&nbsp;&nbsp;  ingest node
  
>kubectl label node r-node-2 r-node-3 r-node-4 es-data=true

>kubectl label node r-node-5 r-node-6 r-node-7 es-master=true

>kubectl label node r-node-6 r-node-7 es-ingest=true

>kubectl get nodes --show-labels

Now, we want to create PersistentVOlumes for data nodes. Given I have only local storage, in the given example we are using local-storage storage class. We are creating 3 PVs, one for each data node, and each volume is going to be tied to specific worker node only, using the nodeAffinity and nodeSelectorTerms. See pv-es-data.yaml.

>kubectl apply -f pv-es-data.yaml

Now you can deploy data stateful set, master deployment and ingest nodes.

>kubectl -n es apply -f es-master-config.yaml
>kubectl -n es apply -f es-master.yaml

>kubectl -n es apply -f es-config-.yaml
>kubectl -n es apply -f es-data-statefulset.yaml

>kubectl -n es apply -f es-ingest-config.yaml
>kubectl -n es apply -f es-ingest.yaml

>kubectl -n es apply -f es-ml-config.yaml
>kubectl -n es apply -f es-ml.yaml

>kubectl -n es apply -f kibana-cm.yaml
>kubectl -n es apply -f kibana.yaml

Optionaly, you can deploy curator config and curator cron job also, which is used to delete indices which are older than certain age based on date in name pattern.

Verify all the pods are up and running:

>kubectl -n es get pods -o wide





