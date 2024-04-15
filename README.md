This command has to be executed automatically  before providers block ??

```aws eks --region us-east-1  update-kubeconfig --name <update-eks-cluste-name>```.

after terraform is executed,we need to edit two files.

```kubectl edit svc prometheus-grafana -n prometheus``` .
Scroll down to the point where you see this ‘type: ClusterIP’ and change it to these exact words:  `LoadBalancer`

```kubectl edit svc prometheus-kube-prometheus-prometheus -n prometheus``` .
Scroll down to the point where you see this ‘type: ClusterIP’ and change it to these exact words:  `LoadBalancer`