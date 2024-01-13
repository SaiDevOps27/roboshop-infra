variable "instances" {
  default = {
    frontend = {
      name = "frontend"
      type = "t3.small"
    }
    mongodb = {
      name = "mongodb"
      type = "t3.small"
    }
    catalogue = {
      name = "catalogue"
      type = "t3.small"
    }

    redis = {
      name = "redis"
      type = "t3.small"
    }
    user = {
      name = "user"
      type = "t3.small"
    }
    cart = {
      name = "cart"
      type = "t3.small"
    }
    mysql = {
      name = "mysql"
      type = "t3.small"
    }
    shipping = {
      name = "shipping"
      type = "t3.small"
    }

    rabbitmq = {
      name = "rabbitmq"
      type = "t3.small"
    }
    payment = {
      name = "payment"
      type = "t3.small"
    }

  }
}

