# Kubernetes Deployment Manifest
resource "kubernetes_deployment_v1" "myapp1" {
  depends_on = [kubernetes_namespace.app]
  metadata {
    name = "myapp1-deployment"
    namespace = "app"
    labels = {
      app = "myapp1"
    }
  } 
 
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "myapp1"
      }
    }

    template {
      metadata {
        labels = {
          app = "myapp1"
        }
      }

      spec {
        container {
          image = "stacksimplify/kubenginx:1.0.0"
          name  = "myapp1-container"
          port {
            container_port = 80
          }
          }
        }
      }
    }
}

