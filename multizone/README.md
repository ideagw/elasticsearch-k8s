
# Three Zone Highly Available ElasticSearch Deployment on Kubernetes Cluster




## Steps

1. Install and optionally customize the local-path storage class as we are using local SSDs for storage and we don't want to manually create PVs.

2. Label nodes to indicate which zone they are present in. We have three zones {a, b, c} and nine nodes (named r1, r2, r3, d1, d2, d3, r4, r5, r6)  with 3 nodes in each zone.

``` 
kubectl label node r1 r2 r3 zone=a
kubectl label node d1 d2 d3 zone=b
kubectl label node r4 r5 r6 zone=c
```

3. Label nodes to indicate which role they would support, i.e. Elastic data, master etc.

```
kubectl label node r1 r2 d1 d2 r4 r5 es-data=yes
kubectl label node r3 d3 r6 es-master=yes
```

4. This way we have 6 data nodes and 3 master nodes such that one master node is available in each zone, and 2 data nodes are available in each zone.

5. Since Elastic ingest nodes and Kibana do not use persistence storage, we leave them free to roam around on any nodes.

6. Look into yaml files for any customizations needed (e.g. kibana.yaml for service configuration).

7. From within the multizone directory, just execute:

``` 
kubectl create ns es
kubectl -n es apply -f .
```
8. Watch for pods as they come along

```
kubectl -n es get pods -o wide
```
9. Create index with 3 shards and one replica, check to ensure that for each shard, its primary and replica are in separate zones.

