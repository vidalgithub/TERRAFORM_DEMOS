## Step-10: Configure kubeconfig for kubectl
```t
# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name hr-stag-eksdemo1
aws eks --region us-east-1 update-kubeconfig --name hr-dev-eksdemo1

# List Worker Nodes
kubectl get nodes
kubectl get nodes -o wide
Observation:
1. Verify the External IP for the node

# Verify Services
kubectl get svc
```


## Step-11: Verify Kubernetes Resources
```t
# List Pods
kubectl get pods -o wide
Observation: 
1. Both app pod should be in Public Node Group 

# List Services
kubectl get svc
kubectl get svc -o wide
Observation:
1. We should see both Load Balancer Service and NodePort service created

# Access Sample Application on Browser
http://<LB-DNS-NAME>
http://abb2f2b480148414f824ed3cd843bdf0-805914492.us-east-1.elb.amazonaws.com
```


## Step-12: Verify Kubernetes Resources via AWS Management console
1. Go to Services -> EC2 -> Load Balancing -> Load Balancers
2. Verify Tabs
   - Description: Make a note of LB DNS Name
   - Instances
   - Health Checks
   - Listeners
   - Monitoring


## Step-13: Node Port Service Port - Update Node Security Group
- **Important Note:** This is not a recommended option to update the Node Security group to open ports to internet, but just for learning and testing we are doing this. 
- Go to Services -> Instances -> Find Private Node Group Instance -> Click on Security Tab
- Find the Security Group with name `eks-remoteAccess-`
- Go to the Security Group (Example Name: sg-027936abd2a182f76 - eks-remoteAccess-d6beab70-4407-dbc7-9d1f-80721415bd90)
- Add an additional Inbound Rule
   - **Type:** Custom TCP
   - **Protocol:** TCP
   - **Port range:** 31280
   - **Source:** Anywhere (0.0.0.0/0)
   - **Description:** NodePort Rule
- Click on **Save rules**

## Step-14: Verify by accessing the Sample Application using NodePort Service
```t
# List Nodes
kubectl get nodes -o wide
Observation: Make a note of the Node External IP

# List Services
kubectl get svc
Observation: Make a note of the NodePort service port "myapp1-nodeport-service" which looks as "80:31280/TCP"

# Access the Sample Application in Browser
http://<EXTERNAL-IP-OF-NODE>:<NODE-PORT>
http://54.165.248.51:31280
```

## Step-15: Remove Inbound Rule added 
- Go to Services -> Instances -> Find Private Node Group Instance -> Click on Security Tab
- Find the Security Group with name `eks-remoteAccess-`
- Go to the Security Group (Example Name: sg-027936abd2a182f76 - eks-remoteAccess-d6beab70-4407-dbc7-9d1f-80721415bd90)
- Remove the NodePort Rule which we added.

## Step-16: Clean-Up
```t
# Delete Kubernetes  Resources
cd 02-k8sresources-terraform-manifests
terraform apply -destroy -auto-approve
rm -rf .terraform*

# Verify Kubernetes Resources
kubectl get pods
kubectl get svc

# Delete EKS Cluster (Optional)
1. As we are using the EKS Cluster with Remote state storage, we can and we will reuse EKS Cluster in next sections
2. Dont delete or destroy EKS Cluster Resources

cd 01-ekscluster-terraform-manifests/
terraform apply -destroy -auto-approve
rm -rf .terraform*
```

## Additional Reference
## Step-00: Little bit theory about Terraform Backends
- Understand little bit more about Terraform Backends
- Where and when Terraform Backends are used ?
- What Terraform backends do ?
- How many types of Terraform backends exists as on today ? 

[![Image](https://stacksimplify.com/course-images/terraform-remote-state-storage-7.png "Terraform on AWS with IAC DevOps and SRE")](https://stacksimplify.com/course-images/terraform-remote-state-storage-7.png)

[![Image](https://stacksimplify.com/course-images/terraform-remote-state-storage-8.png "Terraform on AWS with IAC DevOps and SRE")](https://stacksimplify.com/course-images/terraform-remote-state-storage-8.png)

[![Image](https://stacksimplify.com/course-images/terraform-remote-state-storage-9.png "Terraform on AWS with IAC DevOps and SRE")](https://stacksimplify.com/course-images/terraform-remote-state-storage-9.png)


## References 
- [AWS S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [Terraform Backends](https://www.terraform.io/docs/language/settings/backends/index.html)
- [Terraform State Storage](https://www.terraform.io/docs/language/state/backends.html)
- [Terraform State Locking](https://www.terraform.io/docs/language/state/locking.html)
- [Remote Backends - Enhanced](https://www.terraform.io/docs/language/settings/backends/remote.html)

