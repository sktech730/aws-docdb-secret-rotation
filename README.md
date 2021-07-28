# aws-docdb-secret-rotation

This sample code sets up automated way of rotating amazon document DB password 
through amazon secret manager service

## Prerequisite
AWS account

## Usage
1] Clone the repo

2] Set the following place holder values in "variables.tf" file as per your account and need.
    
    
    set up networking related values

    vpc_id, private-subnet-1, private-subnet-2
    
    set up document db user details (user id and password)

    master_docdb_user,master_docdb_password,sample_app_user,sample_app_usr_password

    set up aws region
    
    user_region

    set deployment bucket realted values in "backend.tf"

    DEPLOYMENT_BUCKET,AWS_PROFILE and AWS_REGION

    Tags

    review the "tags.tf" file add more tags based on need
    
3] PEM file
    
    download the pem file from "https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem" 
    and place it in following folders
    src/docdb_rotate and src/docdb_multiuser_rotate

4] set up application user in amazon document user
    
        db.createUser
        (
            {
                user: "<sample_app_user>",
                pwd: "<sample_app_usr_password>",
                roles: 
                    [{"db":"<sample-docdb-1>", "role":"<desired_role>" }]
            }
        )


    


