# A nice looking Portfolio Website Hosted on AWS

This project shows you how to deploy a nice looking
portfolio website into AWS. The project uses
the static website framework [Jekyll](https://jekyllrb.com/)
and the nice looking [Freelancer Jekyll Theme](https://jekyllthemes.io/theme/freelancer-theme)
that we use for our [own website](https://devops-hamburg.de).

The AWS deployment is configured with AWS CloudFormation.
The Makefile in the root of this repository provides
two targets in order to deploy the website resources and
content.

Running

```bash
make deploy-resources
```

will deploy the following AWS resources:
  * a S3 bucket that contains the website content
  * a S3 bucket for request logs
  * a TLS Certificate used for secure https traffic
  * a CloudFront distribution, AWS content delivery network,
  that will deliver your portolio website
  * a DNS record to point your domain to the CloudFront
  website endpoint
  
 
Finally
 
 ```bash
make deploy-content
``` 

will push the static website content into the S3 bucket created above.


This is it! Visit the [Jekyll documentation](https://jekyllrb.com/docs/) 
to find out how to further work with your new website.
