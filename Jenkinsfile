pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['APPLY', 'DESTROY'], description: 'Choose action to perform')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run the selected action after generating plan?')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        RESOURCE_DIR          = 'eks/resources'
    }
    stages {
        stage('Initialize and Checkout') {
            steps {
                script {
                    // Clean workspace without removing the directory
                    sh 'find . -maxdepth 1 ! -name . -exec rm -rf {} +'
                    // Checkout the Terraform repository
                    dir("eks") {
                        git branch: 'main', url: 'https://github.com/vidalgithub/TERRAFORM_DEMOS.git'
                        sh 'ls -la' // List files to confirm checkout
                        sh 'pwd' // Print working directory
                    }
                }
            }
        }

        stage('Process Infrastructures') {
            parallel {
                stage('APPLY') {
                    when {
                        expression { return params.ACTION == 'APPLY' }
                    }
                    stages {
                        stage('Provision 1 - EKS Private Cluster') {
                            steps {
                                script {
                                    provisionInfrastructure('1-eks-private-cluster', '10-eks-PRIVate-vpc-BG')
                                }
                            }
                        }
                        stage('Provision 2 - AWS LB Controller') {
                            steps {
                                script {
                                    provisionInfrastructure('2-AWS-LB-Controller', '11-aws-LBC-install-terraform-manifests')
                                }
                            }
                        }
                        stage('Provision 3 - EXT DNS') {
                            steps {
                                script {
                                    provisionInfrastructure('3-EXT-DNS', '14-externaldns-install-terraform-manifests')
                                }
                            }
                        }
                        stage('Provision 4 - Metrics Server') {
                            steps {
                                script {
                                    provisionInfrastructure('4-Metrics-Server', '27-tf-k8s-METRICS-SERVER-terraform-manifests')
                                }
                            }
                        }
                        stage('Provision 5 - Cluster AutoScaler') {
                            steps {
                                script {
                                    provisionInfrastructure('5-Cluster-AutoScaler', '26-tf-CA-cluster-autoscaler-install-terraform-manifests')
                                }
                            }
                        }
                        stage('Provision 6 - EBS CSI DRIVER') {
                            steps {
                                script {
                                    provisionInfrastructure('6-EBS-CSI-DRIVER', '06-ebs-EBS-addon-terraform-manifests')
                                }
                            }
                        }
                    }
                }

                stage('DESTROY') {
                    when {
                        expression { return params.ACTION == 'DESTROY' }
                    }
                    stages {
                        stage('Destroy 6 - EBS CSI DRIVER') {
                            steps {
                                script {
                                    destroyInfrastructure('6-EBS-CSI-DRIVER', '06-ebs-EBS-addon-terraform-manifests')
                                }
                            }
                        }
                        stage('Destroy 5 - Cluster AutoScaler') {
                            steps {
                                script {
                                    destroyInfrastructure('5-Cluster-AutoScaler', '26-tf-CA-cluster-autoscaler-install-terraform-manifests')
                                }
                            }
                        }
                        stage('Destroy 4 - Metrics Server') {
                            steps {
                                script {
                                    destroyInfrastructure('4-Metrics-Server', '27-tf-k8s-METRICS-SERVER-terraform-manifests')
                                }
                            }
                        }
                        stage('Destroy 3 - EXT DNS') {
                            steps {
                                script {
                                    destroyInfrastructure('3-EXT-DNS', '14-externaldns-install-terraform-manifests')
                                }
                            }
                        }
                        stage('Destroy 2 - AWS LB Controller') {
                            steps {
                                script {
                                    destroyInfrastructure('2-AWS-LB-Controller', '11-aws-LBC-install-terraform-manifests')
                                }
                            }
                        }
                        stage('Destroy 1 - EKS Private Cluster') {
                            steps {
                                script {
                                    destroyInfrastructure('1-eks-private-cluster', '10-eks-PRIVate-vpc-BG')
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

def provisionInfrastructure(infraName, infraDir) {
    dir("${env.RESOURCE_DIR}/${infraDir}") {
        // Initialize Terraform
        sh 'terraform init'
        
        // Plan Terraform
        sh 'terraform plan -out=tfplan'
        sh 'terraform show -no-color tfplan > tfplan.txt'
        
        // Read the plan file for approval
        def planFile = "${env.RESOURCE_DIR}/${infraDir}/tfplan.txt"
        def plan = readFile planFile
        
        // Approval stage
        if (!params.autoApprove) {
            input message: "Do you want to apply the Terraform plan for ${infraName}?",
                  parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
        }
        
        // Apply the plan
        sh 'terraform apply -input=false tfplan'
    }
}

def destroyInfrastructure(infraName, infraDir) {
    dir("${env.RESOURCE_DIR}/${infraDir}") {
        // Initialize Terraform
        sh 'terraform init'
        
        // Plan Destroy Terraform
        sh 'terraform plan -destroy -out=tfplan-destroy'
        sh 'terraform show -no-color tfplan-destroy > tfplan-destroy.txt'
        
        // Read the plan file for approval
        def planFile = "${env.RESOURCE_DIR}/${infraDir}/tfplan-destroy.txt"
        def plan = readFile planFile
        
        // Approval stage
        if (!params.autoApprove) {
            input message: "Do you want to destroy the Terraform resources for ${infraName}?",
                  parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
        }
        
        // Destroy the plan
        sh 'terraform apply -input=false tfplan-destroy'
    }
}
