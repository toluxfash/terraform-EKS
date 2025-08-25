resource "helm_release" "metrics-server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.8.1"

  values = [
    file("${path.module}/values/metrics-server.yaml")
  ]

  depends_on = [aws_eks_node_group.general]

}