pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['APPLY', 'DESTROY'], description: 'Choose action to perform')
        choice(name: 'INFRASTRUCTURE', choices: [
            '1-eks-private-cluster',
            '2-AWS-LB-Controller',
            '3-EXT-DNS',
            '4-Metrics-Server',
            '5-Cluster-AutoScaler',
            '6-EBS-CSI-DRIVER'
        ], description: 'Choose infrastructure to manage')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically approve the plan and apply it?')
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
                        expression { params.ACTION == 'APPLY' }
                    }
                    stages {
                        stage('Provision Infrastructure') {
                            steps {
                                script {
                                    def infraName = params.INFRASTRUCTURE
                                    def infraDir = getInfraDir(infraName)
                                    provisionInfrastructure(infraName, infraDir)
                                }
                            }
                        }
                    }
                }

                stage('DESTROY') {
                    when {
                        expression { params.ACTION == 'DESTROY' }
                    }
                    stages {
                        stage('Destroy Infrastructure') {
                            steps {
                                script {
                                    def infraName = params.INFRASTRUCTURE
                                    def infraDir = getInfraDir(infraName)
                                    destroyInfrastructure(infraName, infraDir)
                                }
                            }
                        }
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

def getInfraDir(infraName) {
    def infraDirs = [
        '1-eks-private-cluster': '10-eks-PRIVate-vpc-BG',
        '2-AWS-LB-Controller': '11-aws-LBC-install-terraform-manifests',
        '3-EXT-DNS': '14-externaldns-install-terraform-manifests',
        '4-Metrics-Server': '27-tf-k8s-METRICS-SERVER-terraform-manifests',
        '5-Cluster-AutoScaler': '26-tf-CA-cluster-autoscaler-install-terraform-manifests',
        '6-EBS-CSI-DRIVER': '06-ebs-EBS-addon-terraform-manifests'
    ]
    return infraDirs[infraName]
}

def provisionInfrastructure(infraName, infraDir) {
    try {
        dir("${env.RESOURCE_DIR}/${infraDir}") {
            // Initialize Terraform
            sh 'terraform init'
            
            // Plan Terraform
            sh 'terraform plan -out=tfplan'
            sh 'terraform show -no-color tfplan > tfplan.txt'
            
            // Display the contents of the plan files
            echo 'Contents of tfplan file:'
            sh 'terraform show tfplan'
            echo 'Contents of tfplan.txt file:'
            sh 'cat tfplan.txt'
            
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
    } catch (Exception e) {
        error "Error in provisioning ${infraName}: ${e.getMessage()}"
    }
}

def destroyInfrastructure(infraName, infraDir) {
    try {
        dir("${env.RESOURCE_DIR}/${infraDir}") {
            // Initialize Terraform
            sh 'terraform init'
            
            // Plan Destroy Terraform
            sh 'terraform plan -destroy -out=tfplan-destroy'
            sh 'terraform show -no-color tfplan-destroy > tfplan-destroy.txt'
            
            // Display the contents of the destroy plan files
            echo 'Contents of tfplan-destroy file:'
            sh 'terraform show tfplan-destroy'
            echo 'Contents of tfplan-destroy.txt file:'
            sh 'cat tfplan-destroy.txt'
            
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
    } catch (Exception e) {
        error "Error in destroying ${infraName}: ${e.getMessage()}"
    }
}
