workspace extends ../models.dsl {
    model {       
        # Deployment
        prodEnvironment = deploymentEnvironment "Production" {
            deploymentNode "AWS" {
                tags "Amazon Web Services - Cloud"

                route53 = infrastructureNode "Route 53" {
                    tags "Amazon Web Services - Route 53"
                }

                deploymentNode "ap-southeast-1" {
                    tags "Amazon Web Services - Region"


                    deploymentNode "prod-vpc" {
                        tags "Amazon Web Services - VPC"

                        appLoadBalancer = infrastructureNode "Application Load Balancer" {
                            tags "Amazon Web Services - Elastic Load Balancing Application Load Balancer"
                        }

                        s3 = deploymentNode "S3" {
                            tags "Amazon Web Services - Simple Storage Service S3 Standard"
                            
                            containerInstance frontStoreApp
                        }

                        deploymentNode "eks-cluster" {
                            tags "Amazon Web Services - Elastic Kubernetes Service"
                        
                            deploymentNode "private-net-a" {
                                tags "Amazon Web Services - VPC subnet private"

                                deploymentNode "ec2-a" {
                                    tags "Amazon Web Services - EC2 Instance"

                                    backofficeAppInstance = containerInstance backofficeApp
                                    searchWebApiInstance = containerInstance searchWebApi
                                    publicWebApiInstance = containerInstance publicWebApi
                                    adminWebApiInstance = containerInstance adminWebApi
                                    publisherRecurrentUpdateInstance = containerInstance publisherRecurrentUpdater
                                }
                            }
                            deploymentNode "private-net-b" {
                                tags "Amazon Web Services - VPC subnet private"

                                deploymentNode "ec2-b" {
                                    tags "Amazon Web Services - EC2 Instance"

                                    containerInstance bookEventConsumer
                                    containerInstance bookEventStream
                                }

                                deploymentNode "PostgreSQL RDS" {
                                    tags "Amazon Web Services - RDS"
                                    
                                    containerInstance bookstoreDatabase
                                }

                                deploymentNode "Amazon OpenSearch" {
                                    tags "Amazon Web Services - OpenSearch Service"

                                    containerInstance searchDatabase
                                }
                            }
                        }
                    }
                }
            }
            route53 -> appLoadBalancer
            appLoadBalancer -> publicWebApiInstance "Forwards requests to" "[HTTPS]"
            appLoadBalancer -> searchWebApiInstance "Forwards requests to" "[HTTPS]"
            appLoadBalancer -> adminWebApiInstance "Forwards requests to" "[HTTPS]"
        }

        developer = person "Developer" "Internal bookstore platform developer" "User"
        deployWorkflow = softwareSystem "CI/CD Workflow" "Workflow CI/CD for deploying system using AWS Services" "Target System" {
            repository = container "Code Repository" "" "Github"
            pipeline = container "CodePipeline" {
                tags "Amazon Web Services - CodePipeline" "Dynamic Element"
            }
            codeBuilder = container "CodeBuild" "" {
                tags "Amazon Web Services - CodeBuild" "Dynamic Element"
            }
            containerRegistry = container "Amazon ECR" {
                tags "Amazon Web Services - EC2 Container Registry" "Dynamic Element"
            }
            cluster = container "Amazon EKS" {
                tags "Amazon Web Services - Elastic Kubernetes Service" "Dynamic Element"
            }
        }
        developer -> repository
        repository -> pipeline
        pipeline -> codeBuilder
        codeBuilder -> containerRegistry
        codeBuilder -> pipeline
        pipeline -> cluster
    }

    views {
        # deployment <software-system> <environment> <key> <description>
        deployment bookstoreSystem prodEnvironment "Dep-001-PROD" "Cloud Architecture for Bookstore Platform using AWS Services" {
            include *
            #autoLayout lr
        }
        # dynamic <container> <name> <description>
        dynamic deployWorkflow "Dynamic-001-WF" "Bookstore platform deployment workflow" {
            developer -> repository "Commit, and push changes"
            repository -> pipeline "Trigger pipeline job"
            pipeline -> codeBuilder "Download source code, and start build process"
            codeBuilder -> containerRegistry "Upload Docker image with unique tag"
            codeBuilder -> pipeline "Return the build result"
            pipeline -> cluster "Deploy container"
            autoLayout lr
        }

        themes "https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json" "https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json"

        styles {
            element "Dynamic Element" {
                background #ffffff
            }
        }
    }
}