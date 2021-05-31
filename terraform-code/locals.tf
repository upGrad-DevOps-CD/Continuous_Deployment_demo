locals {

  volume_size = "30"
  volume_type = "standard"

  amazon_linux_ami = "ami-0742b4e673072066f"
  user_data        = <<-EOF
          #!/bin/bash
	    EOF
  common_tags = {
    Purpose    = "CML_DEMO"
    Instructor = "nikhilbhat2008@gmail.com"
    Type       = "DeleteMe"
  }
}