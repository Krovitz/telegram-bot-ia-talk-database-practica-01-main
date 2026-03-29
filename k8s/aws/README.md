# https://repost.aws/knowledge-center/eks-alb-ingress-controller-fargate
# https://www.linkedin.com/pulse/generating-api-gateway-rest-endpoints-eks-alb-ingress-srinivasan/

# Kube Config
aws eks update-kubeconfig --region us-west-2 --name <NAME-CLUSTER>

# Load Balancer helm
- helm repo add eks https://aws.github.io/eks-charts

```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
--set clusterName=<NAME-CLUSTER> \
--set region=us-west-2 \
--set vpcId=vpc-<id> \
-n kube-system 
```


## Metrics

- https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html
