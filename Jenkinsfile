pipeline {
    parameters {
        choice(name: 'ACTION', choices: ['APPLY', 'DESTROY'], description: 'Choose action to perform')
        choice(name: 'INFRASTRUCTURE', choices: [
            '1-eks-private-cluster',
            '2-AWS-LB-Controller',
            '3-EXT-DNS',
            '4-Metrics-Server',
            '5-Cluster-AutoScaler',
            '6-EBS-CSI-DRIVER'
        ], description: 'Choose infrastructure to provision')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run the selected action after generating plan?')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        RESOURCE_DIR          = 'eks/resources'
    }
    agent any

    stages {
        stage('Checkout') {
            steps {
                script {
                    sh 'find . -maxdepth 1 ! -name . -exec rm -rf {} +' // Clean workspace without removing the directory
                    dir("eks") {
                        git branch: 'main', url: 'https://github.com/vidalgithub/TERRAFORM_DEMOS.git'
                    }
                }
            }
        }

        stage('Provision') {
            parallel {
                stage('Provision 1 - EKS Private Cluster') {
                    when {
                        expression { params.ACTION == 'APPLY' && params.INFRASTRUCTURE == '1-eks-private-cluster' }
                    }
                    steps {
                        script {
                            def infraDir = '10-eks-PRIVate-vpc-BG'
                            dir("${env.RESOURCE_DIR}/${infraDir}") {
                                sh 'terraform init'
                                sh 'terraform plan -out=tfplan'
                                sh 'terraform show -no-color tfplan > tfplan.txt'
                            }
                        }
                    }
                }

                stage('Provision 2 - AWS LB Controller') {
                    when {
                        expression { params.ACTION == 'APPLY' && params.INFRASTRUCTURE == '2-AWS-LB-Controller' || params.INFRASTRUCTURE == '1-eks-private-cluster' }
                    }
                    steps {
                        script {
                            def infraDir = '11-aws-LBC-install-terraform-manifests'
                            dir("${env.RESOURCE_DIR}/${infraDir}") {
                                sh 'terraform init'
                                sh 'terraform plan -out=tfplan'
                                sh 'terraform show -no-color tfplan > tfplan.txt'
                            }
                        }
                    }
                }

                stage('Provision 3 - EXT DNS') {
                    when {
                        expression { params.ACTION == 'APPLY' && params.INFRASTRUCTURE == '3-EXT-DNS' || params.INFRASTRUCTURE == '2-AWS-LB-Controller' || params.INFRASTRUCTURE == '1-eks-private-cluster' }
                    }
                    steps {
                        script {
                            def infraDir = '14-externaldns-install-terraform-manifests'
                            dir("${env.RESOURCE_DIR}/${infraDir}") {
                                sh 'terraform init'
                                sh 'terraform plan -out=tfplan'
                                sh 'terraform show -no-color tfplan > tfplan.txt'
                            }
                        }
                    }
                }

                stage('Provision 4 - Metrics Server') {
                    when {
                        expression { params.ACTION == 'APPLY' && params.INFRASTRUCTURE == '4-Metrics-Server' || params.INFRASTRUCTURE == '3-EXT-DNS' || params.INFRASTRUCTURE == '2-AWS-LB-Controller' || params.INFRASTRUCTURE == '1-eks-private-cluster' }
                    }
                    steps {
                        script {
                            def infraDir = '27-tf-k8s-METRICS-SERVER-terraform-manifests'
                            dir("${env.RESOURCE_DIR}/${infraDir}") {
                                sh 'terraform init'
                                sh 'terraform plan -out=tfplan'
                                sh 'terraform show -no-color tfplan > tfplan.txt'
                            }
                        }
                    }
                }

                stage('Provision 5 - Cluster AutoScaler') {
                    when {
                        expression { params.ACTION == 'APPLY' && params.INFRASTRUCTURE == '5-Cluster-AutoScaler' || params.INFRASTRUCTURE == '4-Metrics-Server' || params.INFRASTRUCTURE == '3-EXT-DNS' || params.INFRASTRUCTURE == '2-AWS-LB-Controller' || params.INFRASTRUCTURE == '1-eks-private-cluster' }
                    }
                    steps {
                        script {
                            def infraDir = '26-tf-CA-cluster-autoscaler-install-terraform-manifests'
                            dir("${env.RESOURCE_DIR}/${infraDir}") {
                                sh 'terraform init'
                                sh 'terraform plan -out=tfplan'
                                sh 'terraform show -no-color tfplan > tfplan.txt'
                            }
                        }
                    }
                }

                stage('Provision 6 - EBS CSI Driver') {
                    when {
                        expression { params.ACTION == 'APPLY' && params.INFRASTRUCTURE == '6-EBS-CSI-DRIVER' || params.INFRASTRUCTURE == '5-Cluster-AutoScaler' || params.INFRASTRUCTURE == '4-Metrics-Server' || params.INFRASTRUCTURE == '3-EXT-DNS' || params.INFRASTRUCTURE == '2-AWS-LB-Controller' || params.INFRASTRUCTURE == '1-eks-private-cluster' }
                    }
                    steps {
                        script {
                            def infraDir = '06-ebs-EBS-addon-terraform-manifests'
                            dir("${env.RESOURCE_DIR}/${infraDir}") {
                                sh 'terraform init'
                                sh 'terraform plan -out=tfplan'
                                sh 'terraform show -no-color tfplan > tfplan.txt'
                            }
                        }
                    }
                }
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }
            steps {
                script {
                    def infraName = params.INFRASTRUCTURE
                    def infraDir = infraMapping[infraName]
                    def planFile = params.ACTION == 'APPLY' ? "${env.RESOURCE_DIR}/${infraDir}/tfplan.txt" : "${env.RESOURCE_DIR}/${infraDir}/tfplan-destroy.txt"

                    def plan = readFile(planFile)
                    input message: "Do you want to ${params.ACTION.toLowerCase()} the resources?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply or Destroy') {
            steps {
                script {
                    def infraName = params.INFRASTRUCTURE
                    def infraDir = infraMapping[infraName]

                    if (params.ACTION == 'APPLY') {
                        dir("${env.RESOURCE_DIR}/${infraDir}") {
                            sh 'terraform apply -input=false tfplan'
                        }
                    } else if (params.ACTION == 'DESTROY') {
                        // Destroy infrastructure in reverse order
                        def destroyOrder = [
                            '6-EBS-CSI-DRIVER',
                            '5-Cluster-AutoScaler',
                            '4-Metrics-Server',
                            '3-EXT-DNS',
                            '2-AWS-LB-Controller',
                            '1-eks-private-cluster'
                        ]
                        def index = destroyOrder.indexOf(infraName)
                        if (index != -1) {
                            for (int i = index; i >= 0; i--) {
                                def infra = destroyOrder[i]
                                def destroyDir = infraMapping[infra]
                                dir("${env.RESOURCE_DIR}/${destroyDir}") {
                                    sh 'terraform plan -destroy -out=tfplan-destroy'
                                    sh 'terraform apply -input=false tfplan-destroy'
                                }
                            }
                        }
                    } else {
                        error "Invalid action: ${params.ACTION}"
                    }
                }
            }
        }
    }
    post {
        failure {
            echo 'Build failed.'
        }
        success {
            echo 'Build succeeded.'
        }
    }
}
