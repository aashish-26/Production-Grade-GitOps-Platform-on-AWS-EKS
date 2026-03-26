output "vpc_id" { value = module.vpc_mod.vpc_id }
output "private_subnets" { value = module.vpc_mod.private_subnets }
output "public_subnets" { value = module.vpc_mod.public_subnets }
