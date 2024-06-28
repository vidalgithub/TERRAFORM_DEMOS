ISTIO
istioctl x precheck
Install istio 1.20.0
istioctl120 install -y --set profile=demo --revision 1-20-0

Create namespace with istio.io/rev=1-20-0 label
    apiVersion: v1
    kind: Namespace
    metadata:
    labels:
        istio.io/rev: 1-20-0
    name: app

Install your k8s application in the cluster at the above namespace
istioctl analyze
VERIFY that the proxy running in the pods are actually connected to the istiod 1.20.0
istioctl120 proxy-status

Install istio 1.21.0
istioctl121 install -y --set profile=demo --revision 1-21-0

kubectl rollout restart deployment/myapp1-deployment 

Decomission istio
istioctl uninstall -r X-Y-Z
istioctl120 uninstall -r 1-20-0
istioctl121 uninstall -r 1-21-0

UNINSTALL A SINGLE REVISION OF ISTIO
istioctl121 x uninstall --revision 1-21-1
istioctl121 x uninstall --revision=1-21-1

kubectl uncordon ip-10-0-102-180.ec2.internal


