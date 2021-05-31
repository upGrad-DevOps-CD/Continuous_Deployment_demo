resource "aws_ecr_repository" "cd_demo" {
  name = "cd_demo"
}
resource "aws_ecr_repository" "cd_demo_stage" {
  name = "cd_demo_stage"
}