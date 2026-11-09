resource "terraform_data" "network" {
  input = "10.0.0.0/16"
}

resource "terraform_data" "subnet" {
  input = "${terraform_data.network.output}-subnet-a"

  depends_on = [terraform_data.network]
}

resource "terraform_data" "server" {
  input = "${terraform_data.subnet.output}-${var.instance_name}"

  triggers_replace = [
    var.environment
  ]
}
