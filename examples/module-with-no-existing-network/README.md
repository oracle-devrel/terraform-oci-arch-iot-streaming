## Create IoT Streaming module + network deployed by the module
This is an example of how to use the module to deploy IoT Streaming module and network cloud infrastrucutre elements created by the module.
  
### Using this example
Update terraform.tfvars with the required information.

### Deploy the module
Initialize Terraform:
```
$ terraform init
```
View what Terraform plans do before actually doing it:
```
$ terraform plan
```

Create a `terraform.tfvars` file, and specify the following variables:

```
# Authentication
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<finger_print>"
private_key_path     = "<pem_private_key_path>"

# Region
region = "<oci_region>"

# Compartment
compartment_ocid = "<compartment_ocid>"

# ATP_password
atp_admin_password = "<atp_admin_password>"
atp_password       = "<atp_password>"

# OCIR
ocir_user_name         = "<ocir_user_name>"
ocir_user_password     = "<ocir_user_password>"
```

Use Terraform to Provision resources:
```
$ terraform apply
```

### Destroy the module 

Use Terraform to destroy resources:
```
$ terraform destroy -auto-approve
```
