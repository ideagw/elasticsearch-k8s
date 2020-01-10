
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
   Let's create an index named `twitter` with three shards and one replica each
```   
        curl -X PUT "http://10.102.46.55:9200/twitter?pretty" -H 'Content-Type: application/json' -d'
        {
            "settings" : {
            "index" : {
                "number_of_shards" : 3, 
                 "number_of_replicas" : 1 
                }
            }
        }
        '
    Result

        {
        "acknowledged" : true,
            "shards_acknowledged" : true,
            "index" : "twitter"
        }
```

10. Verify that for each shard, the primary and replica allocation is in different zones

        curl http://10.102.46.55:9200/_cat/shards/twitter?pretty=true

        twitter 2 p STARTED 0 230b 10.244.7.242 es-data-b-1
        twitter 2 r STARTED 0 230b 10.244.4.197 es-data-c-0
        twitter 1 p STARTED 0 230b 10.244.1.36  es-data-a-0
        twitter 1 r STARTED 0 230b 10.244.5.212 es-data-c-1
        twitter 0 p STARTED 0 230b 10.244.2.44  es-data-a-1
        twitter 0 r STARTED 0 230b 10.244.6.161 es-data-b-0  

11. Insert some data and search:

       POST twitter/_doc/
       {
        "user" : "elasticuser",
        "post_date" : "2019-11-15T14:12:12",
        "message" : "trying out Elasticsearch"
       }

       {
	  "_index" : "twitter",
	  "_type" : "_doc",
	  "_id" : "352akW8B4tm0-AjGic8M",
	  "_version" : 1,
	  "result" : "created",
	  "_shards" : {
	    "total" : 2,
	    "successful" : 2,
	    "failed" : 0
	  },
	  "_seq_no" : 0,
	  "_primary_term" : 1
	}

12. Bring down pods in zone c

      kubectl -n es scale sts es-master --replicas=2
      kubectl -n es scale sts es-data-c --replicas=0

13. See shards
	curl http://10.102.46.55:9200/_cat/shards/twitter?pretty=true
	twitter 1 p STARTED    0 283b 10.244.1.36  es-data-a-0
	twitter 1 r UNASSIGNED                     
	twitter 2 p STARTED    0 283b 10.244.7.242 es-data-b-1
	twitter 2 r UNASSIGNED                     
	twitter 0 p STARTED    0 283b 10.244.2.44  es-data-a-1
	twitter 0 r STARTED    0 283b 10.244.6.161 es-data-b-0

As you can see, shards 1(replica) and 2(replica) become unassigned. However if there is any data in these, that will still be available when you do search. Similiraly, data can still be inserted in the cluster.

14. Search
	
	curl http://10.102.46.55:9200/twitter/_search?q=user:elastic*

        Result:
	{
	    "user" : "elasticuser",
	    "post_date" : "2019-11-15T14:12:12",
	    "message" : "trying out Elasticsearch"
	}





