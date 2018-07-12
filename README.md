# drone-terraform

drone infrastructure in AWS

## Requirement

AWS Fargate with Amazon ECS is currently only available in the following regions:


|Region Name	|Region|
|-------------|------|
|US East (N. Virginia)	|us-east-1|
|US East (Ohio)	|us-east-2|
|US West (Oregon)	|us-west-2|
|EU West (Ireland)	|eu-west-1|
|Asia Pacific (Tokyo)	|ap-northeast-1|

See [AWS Fargate on Amazon ECS][1] to get more detail information. Service discovery is available in the following AWS Regions:

|Region Name	|Region|
|-------------|------|
|US East (N. Virginia)	|us-east-1|
|US East (Ohio)	|us-east-2|
|US West (N. California)	|us-west-1|
|US West (Oregon)	|us-west-2|
|EU West (Ireland)	|eu-west-1|

See [AWSService Discovery][2] to get more detail information.

[1]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
[2]:https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html
