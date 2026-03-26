$ErrorActionPreference = "Stop"

$region = "ap-south-1"
$clusterName = "gitops-dev-cluster"
$accountId = "848928399250"
$queueArn = "arn:aws:sqs:${region}:${accountId}:gitops-app-queue"

Write-Host "Fetching OIDC issuer for cluster $clusterName..."
$issuer = aws eks describe-cluster --name $clusterName --region $region --query "cluster.identity.oidc.issuer" --output text
if (-not $issuer) { throw "OIDC issuer not found." }
$issuerHost = $issuer -replace "^https://", ""

Write-Host "Checking for existing OIDC provider..."
$providerArn = $null
$providerArns = aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[].Arn" --output text
if ($providerArns) {
  foreach ($arn in $providerArns -split "\s+") {
    $url = aws iam get-open-id-connect-provider --open-id-connect-provider-arn $arn --query "Url" --output text
    if ($url -eq $issuerHost) {
      $providerArn = $arn
      break
    }
  }
}
if (-not $providerArn) {
  Write-Host "Creating OIDC provider for $issuer..."
  $thumbprint = "9e99a48a9960b14926bb7f3b02e22da0afd50a49"
  $providerArn = aws iam create-open-id-connect-provider --url $issuer --client-id-list sts.amazonaws.com --thumbprint-list $thumbprint --query "OpenIDConnectProviderArn" --output text
}

Write-Host "Ensuring IAM policies exist..."
$apiPolicyName = "gitops-api-sqs"
$workerPolicyName = "gitops-worker-sqs"

$apiPolicyArn = aws iam list-policies --scope Local --query "Policies[?PolicyName=='$apiPolicyName'].Arn | [0]" --output text
if ($apiPolicyArn -eq "None") {
  $apiPolicyPath = Join-Path $PSScriptRoot "api-sqs-policy.json"
  $apiPolicyTemplate = @'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["sqs:SendMessage", "sqs:GetQueueUrl"],
      "Resource": "__QUEUE_ARN__"
    }
  ]
}
'@
  $apiPolicyDoc = $apiPolicyTemplate -replace "__QUEUE_ARN__", $queueArn
  $apiPolicyDoc | Set-Content -Encoding Ascii $apiPolicyPath
  $apiPolicyArn = aws iam create-policy --policy-name $apiPolicyName --policy-document file://$apiPolicyPath --query "Policy.Arn" --output text
  Remove-Item -Force $apiPolicyPath
}

$workerPolicyArn = aws iam list-policies --scope Local --query "Policies[?PolicyName=='$workerPolicyName'].Arn | [0]" --output text
if ($workerPolicyArn -eq "None") {
  $workerPolicyPath = Join-Path $PSScriptRoot "worker-sqs-policy.json"
  $workerPolicyTemplate = @'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:ChangeMessageVisibility", "sqs:GetQueueAttributes"],
      "Resource": "__QUEUE_ARN__"
    }
  ]
}
'@
  $workerPolicyDoc = $workerPolicyTemplate -replace "__QUEUE_ARN__", $queueArn
  $workerPolicyDoc | Set-Content -Encoding Ascii $workerPolicyPath
  $workerPolicyArn = aws iam create-policy --policy-name $workerPolicyName --policy-document file://$workerPolicyPath --query "Policy.Arn" --output text
  Remove-Item -Force $workerPolicyPath
}

Write-Host "Creating/attaching roles..."
$roles = @(
  @{ Name = "gitops-api-dev";     Namespace = "dev";     ServiceAccount = "api-sa";    PolicyArn = $apiPolicyArn },
  @{ Name = "gitops-api-staging"; Namespace = "staging"; ServiceAccount = "api-sa";    PolicyArn = $apiPolicyArn },
  @{ Name = "gitops-api-prod";    Namespace = "prod";    ServiceAccount = "api-sa";    PolicyArn = $apiPolicyArn },
  @{ Name = "gitops-worker-dev";     Namespace = "dev";     ServiceAccount = "worker-sa"; PolicyArn = $workerPolicyArn },
  @{ Name = "gitops-worker-staging"; Namespace = "staging"; ServiceAccount = "worker-sa"; PolicyArn = $workerPolicyArn },
  @{ Name = "gitops-worker-prod";    Namespace = "prod";    ServiceAccount = "worker-sa"; PolicyArn = $workerPolicyArn }
)

foreach ($role in $roles) {
  $roleArn = $null
  try {
    $roleArn = aws iam get-role --role-name $role.Name --query "Role.Arn" --output text 2>$null
  } catch { }

  if (-not $roleArn) {
    $trustPath = Join-Path $PSScriptRoot "trust-$($role.Name).json"
    $trustTemplate = @'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Federated": "__PROVIDER_ARN__" },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "__ISSUER_HOST__:sub": "system:serviceaccount:__NAMESPACE__:__SERVICE_ACCOUNT__",
          "__ISSUER_HOST__:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
'@
    $trustDoc = $trustTemplate -replace "__PROVIDER_ARN__", $providerArn
    $trustDoc = $trustDoc -replace "__ISSUER_HOST__", $issuerHost
    $trustDoc = $trustDoc -replace "__NAMESPACE__", $role.Namespace
    $trustDoc = $trustDoc -replace "__SERVICE_ACCOUNT__", $role.ServiceAccount
    $trustDoc | Set-Content -Encoding Ascii $trustPath

    aws iam create-role --role-name $role.Name --assume-role-policy-document file://$trustPath --query "Role.Arn" --output text | Out-Null
    Remove-Item -Force $trustPath
  }

  aws iam attach-role-policy --role-name $role.Name --policy-arn $role.PolicyArn | Out-Null
}

Write-Host "IRSA roles and policies are ready."
