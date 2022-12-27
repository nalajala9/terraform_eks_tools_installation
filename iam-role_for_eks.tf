# Get the policy by name
data "aws_iam_policy" "required-policy" {
  name = "AdministratorAccess"
}

# Create the role
resource "aws_iam_role" "admin-role" {
  name = "eks-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach-role" {
  role       = aws_iam_role.admin-role.name
  policy_arn = data.aws_iam_policy.required-policy.arn
}

# Attach the role to an instance profile
resource "aws_iam_instance_profile" "eks_profile" {
  name = "eks-ec2-admin-profile"
  role = aws_iam_role.admin-role.name
}