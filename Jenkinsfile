pipeline {
    agent any

    parameters {
        string(name: 'ACTION', defaultValue: 'APPLY', description: 'Action to perform (APPLY/DESTROY)')
        booleanParam(name: 'autoApprove', defaultValue: true, description: 'Automatically approve changes')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Process Infrastructures') {
            parallel {
                stage('APPLY') {
                    when {
                        expression { return params.ACTION == 'APPLY' }
                    }
                    steps {
                        script {
                            def infrastructures = [
                                [name: '1-eks-private-cluster', dir: '10-eks-private-vpc-BG'],
                                [name: '2-AWS-LB-Controller', dir: '11-aws-LBC-install-terraform-manifests'],
                                [name: '3-EXT-DNS', dir: '14-externaldns-install-terraform-manifests'],
                                [name: '4-Metrics-Server', dir: '27-tf-k8s-metrics-server-terraform-manifests'],
                                [name: '5-Cluster-AutoScaler', dir: '26-tf-CA-cluster-autoscaler-install-terraform-manifests'],
                                [name: '6-EBS-CSI-DRIVER', dir: '06-ebs-EBS-addon-terraform-manifests']
                            ]
                            for (infra in infrastructures) {
                                echo "Provisioning ${infra.name} in ${infra.dir}"
                                dir("${env.RESOURCE_DIR}/${infra.dir}") {
                                    // Assuming you have a method to handle the provisioning
                                    provisionInfrastructure(infra.name, infra.dir)
                                }
                            }
                        }
                    }
                }

                stage('DESTROY') {
                    when {
                        expression { return params.ACTION == 'DESTROY' }
                    }
                    steps {
                        script {
                            def infrastructures = [
                                [name: '6-EBS-CSI-DRIVER', dir: '06-ebs-EBS-addon-terraform-manifests'],
                                [name: '5-Cluster-AutoScaler', dir: '26-tf-CA-cluster-autoscaler-install-terraform-manifests'],
                                [name: '4-Metrics-Server', dir: '27-tf-k8s-metrics-server-terraform-manifests'],
                                [name: '3-EXT-DNS', dir: '14-externaldns-install-terraform-manifests'],
                                [name: '2-AWS-LB-Controller', dir: '11-aws-LBC-install-terraform-manifests'],
                                [name: '1-eks-private-cluster', dir: '10-eks-private-vpc-BG']
                            ]
                            // Reverse the order for DESTROY
                            def reverseInfrastructures = infrastructures.reverse()
                            for (infra in reverseInfrastructures) {
                                echo "Destroying ${infra.name} in ${infra.dir}"
                                dir("${env.RESOURCE_DIR}/${infra.dir}") {
                                    // Assuming you have a method to handle the destruction
                                    destroyInfrastructure(infra.name, infra.dir)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

def provisionInfrastructure(name, dir) {
    echo "Provisioning infrastructure: ${name} in directory: ${dir}"
    // Add actual provisioning logic here
}

def destroyInfrastructure(name, dir) {
    echo "Destroying infrastructure: ${name} in directory: ${dir}"
    // Add actual destruction logic here
}
