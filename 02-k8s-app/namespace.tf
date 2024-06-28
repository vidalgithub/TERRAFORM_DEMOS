resource "kubernetes_namespace" "app" {
  metadata {
    labels = {
      "istio.io/rev" = "1-20-0"
    }
    name = "app"
  }
}
