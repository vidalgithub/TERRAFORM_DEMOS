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
                    echo 'Cleaning workspace...'
                    // Clean workspace without removing the directory
                    sh 'find . -maxdepth 1 ! -name . -exec rm -rf {} +'
                    
                    echo 'Checking out the repository...'
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
    steps {
        script {
            echo 'Starting infrastructure processing...'
            def infrastructures = [
                [name: '1-eks-private-cluster', dir: '10-eks-private-vpc-BG'],
                [name: '2-AWS-LB-Controller', dir: '11-aws-LBC-install-terraform-manifests'],
                [name: '3-EXT-DNS', dir: '14-externaldns-install-terraform-manifests'],
                [name: '4-Metrics-Server', dir: '27-tf-k8s-metrics-server-terraform-manifests'],
                [name: '5-Cluster-AutoScaler', dir: '26-tf-CA-cluster-autoscaler-install-terraform-manifests'],
                [name: '6-EBS-CSI-DRIVER', dir: '06-ebs-EBS-addon-terraform-manifests']
            ]
            
            if (params.ACTION == 'APPLY') {
                echo 'Starting APPLY stages...'
                for (infra in infrastructures) {
                    echo "Provisioning ${infra.name} in ${infra.dir}"
                    provisionInfrastructure(infra.name, infra.dir)
                }
            } else if (params.ACTION == 'DESTROY') {
                echo 'Starting DESTROY stages...'
                for (infra in infrastructures) {
                    echo "Destroying ${infra.name} in ${infra.dir}"
                    destroyInfrastructure(infra.name, infra.dir)
                }
            } else {
                error "Invalid ACTION parameter: ${params.ACTION}"
            }
        }
    }
}



    }
}

def provisionInfrastructure(name, dir) {
    try {
        echo "Starting provision of ${infra.name} in directory ${env.RESOURCE_DIR}/${infra.dir}"
        dir("${env.RESOURCE_DIR}/${infra.dir}") {
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
            def planFile = "${env.RESOURCE_DIR}/${infra.dir}/tfplan.txt"
            if (fileExists(planFile)) {
                def plan = readFile planFile
                
                // Approval stage
                if (!params.autoApprove) {
                    input message: "Do you want to apply the Terraform plan for ${infra.name}?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
                
                // Apply the plan
                sh 'terraform apply -input=false tfplan'
            } else {
                error "Plan file ${planFile} does not exist"
            }
        }
    } catch (Exception e) {
        error "Error in provisioning ${infra.name}: ${e.getMessage()}"
    }
}

def destroyInfrastructure(name, dir) {
    try {
        echo "Starting destruction of ${infra.name} in directory ${env.RESOURCE_DIR}/${infra.dir}"
        dir("${env.RESOURCE_DIR}/${infra.dir}") {
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
            def planFile = "${env.RESOURCE_DIR}/${infra.dir}/tfplan-destroy.txt"
            if (fileExists(planFile)) {
                def plan = readFile planFile
                
                // Approval stage
                if (!params.autoApprove) {
                    input message: "Do you want to destroy the Terraform resources for ${infra.name}?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
                
                // Destroy the plan
                sh 'terraform apply -input=false tfplan-destroy'
            } else {
                error "Plan file ${planFile} does not exist"
            }
        }
    } catch (Exception e) {
        error "Error in destroying ${infra.name}: ${e.getMessage()}"
    }
}
