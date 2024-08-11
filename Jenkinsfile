pipeline {
    agent {
        docker { 
            image 'vidaldocker/mastertf:kn1.0.2' 
            //args '--entrypoint=""'  // Reset entrypoint
        }
    }
    environment {
        RESOURCE_DIR = "${env.WORKSPACE}/resources"
        vaultUrl = credentials('vaultUrl')
        HELM_HOME = "${env.WORKSPACE}/.helm"
        HELM_CACHE_HOME = "${env.WORKSPACE}/.helm/cache"
        HELM_CONFIG_HOME = "${env.WORKSPACE}/.helm/config"
        XDG_CACHE_HOME = "${env.WORKSPACE}/.cache"
    }
    parameters {
        choice(name: 'ACTION', choices: ['APPLY', 'DESTROY'], description: 'Action to perform (APPLY/DESTROY)')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically approve changes')
    }
    stages {
        stage('Clean Workspace') {
            steps {
                script {
                    echo 'Cleaning workspace...'
                    sh 'find . -maxdepth 1 ! -name . -exec rm -rf {} +'
                }
            }
        }
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
                                [name: '1-eks-private-cluster', dir: '10-eks-PRIVate-vpc-BG'],
                                [name: '2-AWS-LB-Controller', dir: '11-aws-LBC-install-terraform-manifests'],
                                [name: '3-EXT-DNS', dir: '14-externaldns-install-terraform-manifests'],
                                [name: '4-Metrics-Server', dir: '27-tf-k8s-METRICS-SERVER-terraform-manifests'],
                                [name: '5-Cluster-AutoScaler', dir: '26-tf-CA-cluster-autoscaler-install-terraform-manifests'],
                                [name: '6-EBS-CSI-DRIVER', dir: '06-ebs-EBS-addon-terraform-manifests']
                            ]
                            withVault(configuration: [disableChildPoliciesOverride: false, timeout: 60, vaultCredentialId: 'vaultCred', vaultUrl: env.vaultUrl], vaultSecrets: [[path: 'mycreds/aws-creds/vault-admin', secretValues: [[envVar: 'AWS_ACCESS_KEY_ID', vaultKey: 'access_key_id'], [envVar: 'AWS_SECRET_ACCESS_KEY', vaultKey: 'secret_access_key']]]]) {
                                for (infra in infrastructures) {
                                    echo "Provisioning ${infra.name} in ${infra.dir}"
                                    sh '''
                                       export HELM_HOME="${HELM_HOME}"
                                       export HELM_CACHE_HOME="${HELM_CACHE_HOME}"
                                       export HELM_CONFIG_HOME="${HELM_CONFIG_HOME}"
                                       export XDG_CACHE_HOME="${XDG_CACHE_HOME}"
                                       terraform version
                                       helm version
                                       vault version
                                    '''
                                    dir("${env.RESOURCE_DIR}/${infra.dir}") {
                                        sh "ls -la"
                                        provisionInfrastructure(infra.name, infra.dir)
                                    }
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
                                [name: '1-eks-private-cluster', dir: '10-eks-PRIVate-vpc-BG'],
                                [name: '2-AWS-LB-Controller', dir: '11-aws-LBC-install-terraform-manifests'],
                                [name: '3-EXT-DNS', dir: '14-externaldns-install-terraform-manifests'],
                                [name: '4-Metrics-Server', dir: '27-tf-k8s-METRICS-SERVER-terraform-manifests'],
                                [name: '5-Cluster-AutoScaler', dir: '26-tf-CA-cluster-autoscaler-install-terraform-manifests'],
                                [name: '6-EBS-CSI-DRIVER', dir: '06-ebs-EBS-addon-terraform-manifests']
                            ]
                            def reverseInfrastructures = infrastructures.reverse()
                            withVault(configuration: [disableChildPoliciesOverride: false, timeout: 60, vaultCredentialId: 'vaultCred', vaultUrl: env.vaultUrl], vaultSecrets: [[path: 'mycreds/aws-creds/vault-admin', secretValues: [[envVar: 'AWS_ACCESS_KEY_ID', vaultKey: 'access_key_id'], [envVar: 'AWS_SECRET_ACCESS_KEY', vaultKey: 'secret_access_key']]]]) {
                                for (infra in reverseInfrastructures) {
                                    echo "Destroying ${infra.name} in ${infra.dir}"
                                    sh 'terraform version'
                                    sh 'helm version'
                                    dir("${env.RESOURCE_DIR}/${infra.dir}") {
                                        sh "ls -la"
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
    post {
        always {
            slackSend(channel: '#jenkins-pipelines', color: '#FFFF00', message: "Build started for ${env.JOB_NAME} (${env.BUILD_NUMBER})")
        }
        aborted {
            slackSend(channel: '#jenkins-pipelines', color: '#FF0000', message: "Build aborted for ${env.JOB_NAME} (${env.BUILD_NUMBER})")
        }
        failure {
            slackSend(channel: '#jenkins-pipelines', color: '#FF0000', message: "Build failed for ${env.JOB_NAME} (${env.BUILD_NUMBER})")
        }
        notBuilt {
            slackSend(channel: '#jenkins-pipelines', color: '#AAAAAA', message: "Build not built for ${env.JOB_NAME} (${env.BUILD_NUMBER})")
        }
        success {
            slackSend(channel: '#jenkins-pipelines', color: '#00FF00', message: "Build succeeded for ${env.JOB_NAME} (${env.BUILD_NUMBER})")
        }
        unstable {
            slackSend(channel: '#jenkins-pipelines', color: '#FFFF00', message: "Build unstable for ${env.JOB_NAME} (${env.BUILD_NUMBER})")
        }
        regression {
            slackSend(channel: '#jenkins-pipelines', color: '#FF0000', message: "Build regressed for ${env.JOB_NAME} (${env.BUILD_NUMBER})")
        }
        fixed {
            slackSend(channel: '#jenkins-pipelines', color: '#00FF00', message: "Build back to normal for ${env.JOB_NAME} (${env.BUILD_NUMBER})")
        }
    }
}

def provisionInfrastructure(name, dir) {
    try {
        echo "Starting provision of ${name} in directory ${env.RESOURCE_DIR}/${dir}"
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
        def planFile = "${env.RESOURCE_DIR}/${dir}/tfplan.txt"
        if (fileExists(planFile)) {
            def plan = readFile planFile
            
            // Approval stage
            if (!params.autoApprove) {
                input message: "Do you want to apply the Terraform plan for ${name}?",
                      parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
            }
            
            // Apply the plan
            sh 'terraform apply -input=false tfplan'
        } else {
            error "Plan file ${planFile} does not exist"
        }
    } catch (Exception e) {
        error "Error in provisioning ${name}: ${e.getMessage()}"
    }
}

def destroyInfrastructure(name, dir) {
    try {
        echo "Starting destruction of ${name} in directory ${env.RESOURCE_DIR}/${dir}"
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
        def planFile = "${env.RESOURCE_DIR}/${dir}/tfplan-destroy.txt"
        if (fileExists(planFile)) {
            def plan = readFile planFile
            
            // Approval stage
            if (!params.autoApprove) {
                input message: "Do you want to destroy the Terraform resources for ${name}?",
                      parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
            }
            
            // Destroy the plan
            sh 'terraform apply -input=false tfplan-destroy'
        } else {
            error "Plan file ${planFile} does not exist"
        }
    } catch (Exception e) {
        error "Error in destroying ${name}: ${e.getMessage()}"
    }
}
