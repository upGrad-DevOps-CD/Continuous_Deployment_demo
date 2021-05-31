output "JenkinsServerIP" {
  description = "Ip of Jenkins Server"
  value       = aws_instance.JenkinsServer.public_ip
}