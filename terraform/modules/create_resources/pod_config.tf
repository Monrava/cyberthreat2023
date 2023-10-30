################################################################################
resource "kubernetes_namespace" "namespace_demo" {
  metadata {
    annotations = {
      name = "namespace-demo"
    }

    labels = {
      team = "demo"
    }
    name = "namespace-demo"
  }
  timeouts {
    delete = "10m"
  }
}
###############################################################################
resource "kubernetes_namespace" "namespace_test" {
  metadata {
    annotations = {
      name = "namespace-test"
    }

    labels = {
      team = "demo"
    }
    name = "namespace-test"
  }
  timeouts {
    delete = "10m"
  }
}
###############################################################################
resource "kubernetes_namespace" "namespace_demo_mem_dump" {
  metadata {
    annotations = {
      name = "namespace-demo-mem-dump"
    }

    labels = {
      team = "demo"
    }
    name = "namespace-demo-mem-dump"
  }
  timeouts {
    delete = "30m"
  }
}
#################################################################################
resource "kubernetes_pod" "pod_node_affinity_demo_hello_app" {
  metadata {
    name = "pod-node-affinity-demo-hello-app-new"
    namespace = kubernetes_namespace.namespace_demo.metadata[0].name
  }
  spec {
    affinity {
      # Below config specifies which node to add the new pod to.
      node_affinity {
        required_during_scheduling_ignored_during_execution {
          node_selector_term {
            match_expressions {
              key      = "team"
              operator = "In"
              # Values are the labels that a node has
              values   = ["demo"]
            }
          }
        }
      }
    }
    container {
      name  = "hello-app-container"
      image = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0"
    }
  }
}
#################################################################################
resource "kubernetes_pod" "pod_node_affinity_nginx" {
  metadata {
    name = "pod-node-affinity-nginx"
    namespace = kubernetes_namespace.namespace_test.metadata[0].name
  }
  spec {
    affinity {
      # Below config specifies which node to add the new pod to.
      node_affinity {
        required_during_scheduling_ignored_during_execution {
          node_selector_term {
            match_expressions {
              key      = "team"
              operator = "In"
              # Values are the labels that a node has
              values   = ["demo"]
            }
          }
        }
      }
    }
    container {
      name  = "nginx"
      image = "gcr.io/cloud-marketplace/google/nginx1:latest"
    }
  }
}
#################################################################################
resource "kubernetes_pod" "pod_node_affinity_memory_dump" {
metadata {
  name = "pod-node-affinity-mem-dump"
  namespace = kubernetes_namespace.namespace_demo_mem_dump.metadata[0].name
}
spec {
  affinity {
    # Below config specifies which node to add the new pod to.
    node_affinity {
      required_during_scheduling_ignored_during_execution {
        node_selector_term {
          match_expressions {
            key      = "team"
            operator = "In"
            # Values are the labels that a node has
            values   = ["demo"]
          }
        }
      }
    }
  }
  container {
    name  = "avml-container"
    image = "gcr.io/${var.pid}/avml_image:latest"
    security_context {
        privileged = "true"
        capabilities {
          add = ["CAP_NET_ADMIN", "CAP_SYS_ADMIN"]
        }
      }
    }
  }
}
#################################################################################
resource "kubernetes_pod" "pod_node_affinity_attacker_pod" {
  metadata {
    name = "pod-node-affinity-demo-attacker-pod"
    #namespace = "namespace-demo"
  }
  spec {
    affinity {
      # Below config specifies which node to add the new pod to.
      node_affinity {
        required_during_scheduling_ignored_during_execution {
          node_selector_term {
            match_expressions {
              #Example kubernetes.io/hostname: gke-demo-gke-clus-demo-gke-node-023fc3b1-xp06
              # https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/
              key      = "team"
              operator = "In"
              # Values are the labels that a node has
              values   = ["demo"]
            }
          }
        }
      }
    }
    container {
      name  = "attacker-container"
      image = "gcr.io/${var.pid}/attacker_image:latest"
    }
  }
}
#################################################################################