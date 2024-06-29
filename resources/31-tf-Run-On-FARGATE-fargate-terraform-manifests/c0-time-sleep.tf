# Wait 10 seconds after ACM Certificate Resource is created and changed its Certificate status to ISSUED
### NOTE: I implemented this (for 10 seconds) to solve a problem: the app was not showing in the browser and nslookup <hostname> was giving the following message:
### Non-authoritative answer:
### *** Can't find tfingress-crossns-demo401.kloudevsecops.com: No answer
### It then solve the problem

resource "time_sleep" "wait_60_seconds" {
  # depends_on = [aws_acm_certificate.acm_cert]
  depends_on = [aws_acm_certificate_validation.acm_cert] # Make sure the certificate is created and validated, so it can then be take in account by the ingress resource in annotation "alb.ingress.kubernetes.io/certificate-arn" 
  create_duration = "15s"
}
