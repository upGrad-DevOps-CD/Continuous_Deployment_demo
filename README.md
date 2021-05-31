# This Repository contains code for CD module demo_flask_app
Demo Video
https://drive.google.com/file/d/1NDdJHep-9HTbZshoGL5g-FsxQxkJnEyC/view?usp=sharing

**Note replace 956684297917 with your aws account id wherever applicable** 

## Jenkins Server
 You can use packer tool https://www.packer.io/docs/install  to build an ami for jenkins and then use that ami for launching jenkins server with all dependencies installed.

 You will need to update aws_account_id var in install_jenkins.yml for using packer to your aws account id

 ```
 export AWS_ACCESS_KEY_ID="anaccesskey"
 export AWS_SECRET_ACCESS_KEY="asecretkey"
 packer build jenkins_ami.pkr.hcl 
 ```
 Use the ami to create Jenkins Server
 
 By default Username and password is set to admin
 or change password by editing after logging to jenkins

 Make sure you restrict security group to your ip for Jenkins Instance
 
 Incase of Manual Installation:

 - Install heroku cli
 - Install blueocean plugin in jenkins
 - Install git ans github plugin in jenkins
 - Install docker in jenkins and make sure jenkins is configured to work with jenkins

## ecr repository login
For ecr login add following thing to ~/.docker/config.json for jenkins user if the jenkins instance is configured with all required IAM roles

This tool is already installed and taken care of in ami 
  ```
  {
	"credHelpers": {
		"public.ecr.aws": "ecr-login",
		"{{ aws_account_id}}.dkr.ecr.us-east-1.amazonaws.com": "ecr-login"
	}
}
```

## Selenium Test Preparation
 Follow steps provided at this url: https://selenium-python.readthedocs.io/
 run by python3 ./tests/selenium_test.py

## Heroku Deployment Preparations

For Deploying Application to Heroku We need to create:
    - Heroku Account
    - Ec2 Instance(Jenkins_Server) with various plugins installed using packer ami
    - Heroku api token
    - Heroku app -> create it though api or heroku_cli
    - heroku_cli installed on jenkins
    - jenkins ami created through packer has this already installed!

## Ecs  Deployment Preparations Required
For Deploying to Aws in ecs we need to create:

- Ec2 Instance(Jenkins_Server)
- ECS cluster services and LoadBalancers for them
- IAM Role with following permissions for ECS and ECR for jenkins
    ```
    {
               Statement = [
                   {
                       Action   = [
                           "ecs:UpdateService",
                           "ecs:DescribeServices",
                        ]
                       Effect   = "Allow"
                       Resource = "arn:aws:ecs:*:*:service/*"
                       Sid      = "VisualEditor0"
                    },
                   {
                       Action   = "ecs:ListServices"
                       Effect   = "Allow"
                       Resource = "*"
                       Sid      = "VisualEditor1"
                    },
                ]
               Version   = "2012-10-17"
            }
    ```
    ```
    {
              Statement = [
                  {
                      Action   = "ecr:ListImages"
                      Effect   = "Allow"
                      Resource = "arn:aws:ecr:*:*:repository/*"
                      Sid      = "VisualEditor0"
                    },
                   {
                      Action   = "ecr:GetAuthorizationToken"
                      Effect   = "Allow"
                      Resource = "*"
                      Sid      = "VisualEditor1"
                    },
                  {
                      Action   = [
                           "ecr:GetDownloadUrlForLayer",
                           "ecr:BatchGetImage",
                           "ecr:CompleteLayerUpload",
                           "ecr:DescribeImages",
                           "ecr:DescribeRepositories",
                           "ecr:UploadLayerPart",
                           "ecr:ListImages",
                           "ecr:InitiateLayerUpload",
                           "ecr:BatchCheckLayerAvailability",
                           "ecr:GetRepositoryPolicy",
                           "ecr:PutImage",
                        ]
                       Effect   = "Allow"
                       Resource = "arn:aws:ecr:us-east-1:*"
                       Sid      = "VisualEditor2"
                    },
                ]
              Version   = "2012-10-17"
            }
    ```



***These Steps can be automated by Using Terraform***

### Terraform Instructions
Inorder to Create Required Resources for the Demo:

- You Need ***amazon access keys*** which you will need to set as environment variable while running export command
- You Need a ***ssh key pair*** whose name will be required while running terraform.
- ***Your Public Ip*** which you need to provide while running terraform
- Once Done Follow the Instructions Below to Plan , Create Resources
- ***Destroy the Resources only once demo is completed***



#### How to run plan step to see what things terraform will do

```
cd terraform-code
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-east-1"
terraform plan
```

#### How to apply  terraform plan output and actually create Resources

```
cd terraform-cdoe
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-east-1"
terraform apply -auto-approve
```

#### How to Destroy Resources ***once demo is completed***
```
cd terraform-code
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-east-1"
terraform destroy
```

### Once you have applied terraform code or created the requirements manually ###

- Navigate to Jenkins Url
- Create a Manual Job on Jenkins or Pipeline
- More details can be found in demo docs


***Destroy the AWS Resources using terraform destroy command as described earlier*** 


