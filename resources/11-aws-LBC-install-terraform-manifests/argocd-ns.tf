resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    # annotations = {
    #   name = "example-annotation"
    # }

    # labels = {
    #   mylabel = "label-value"
    # }

    name = "argocd"
  }
}
