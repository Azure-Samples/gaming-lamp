variable "vmssautoscalermaxcount" {
  type = number
  default = 10
}

variable "vmssautoscalermincount" {
  type = number
  default = 2
}

variable "vmssautoscaleroutincrease" {
  type = number
  default = 1
}

variable "vmssautoscalerindecrease" {
  type = number
  default = 1
}

variable "vmssautoscalerupthreshold" {
  type = number
  default = 50
}

variable "vmssautoscaleruptimewindow" {
  type = string
  default = "PT5M"
}

variable "vmssautoscalerdownthreshold" {
  type = number
  default = 30
}

variable "vmssautoscalerdowntimewindow" {
  type = string
  default = "PT5M"
}

resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "${var.prefix}Autoscaler"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  target_resource_id  = "${azurerm_virtual_machine_scale_set.main.id}"

  profile {
    name  = "defaultProfile"

    capacity {
      default = var.vmssvmtocreate
      minimum = var.vmssautoscalermincount
      maximum = var.vmssautoscalermaxcount
    }

    rule {
      metric_trigger {
        metric_name         = "Percentage CPU"
        metric_resource_id  = "${azurerm_virtual_machine_scale_set.main.id}"
        time_grain          = "PT1M"
        statistic           = "Average"
        time_window         = var.vmssautoscaleruptimewindow
        time_aggregation    = "Average"
        operator            = "GreaterThan"
        threshold           = var.vmssautoscalerupthreshold
      }

      scale_action {
        direction           = "Increase"
        type                = "ChangeCount"
        value               = var.vmssautoscaleroutincrease
        cooldown            = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name         = "Percentage CPU"
        metric_resource_id  = "${azurerm_virtual_machine_scale_set.main.id}"
        time_grain          = "PT1M"
        statistic           = "Average"
        time_window         = var.vmssautoscalerdowntimewindow
        time_aggregation    = "Average"
        operator            = "LessThan"
        threshold           = var.vmssautoscalerdownthreshold
      }

      scale_action {
        direction           = "Decrease"
        type                = "ChangeCount"
        value               = var.vmssautoscalerindecrease
        cooldown            = "PT1M"
      }
    }
  }
}