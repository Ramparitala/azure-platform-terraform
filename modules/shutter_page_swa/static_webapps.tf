data "template_file" "staticwebapp" {
  template = file("${path.module}/templates/static_webapps.json")
}

resource "azurerm_template_deployment" "static_webapp" {
  for_each = { for frontend in var.shutter_apps : frontend.name => frontend if !contains([
    "jui-redirect",
    "fact-redirect"], frontend.name)
  }

  template_body       = data.template_file.staticwebapp.rendered
  name                = "${each.value.name}"
  deployment_mode     = "Incremental"
  resource_group_name = data.azurerm_resource_group.shutter.name

  parameters = {
    name = "hmcts-shutter-${each.value.name}"
    location = "westeurope"
    repositoryUrl = var.repositoryUrl
    appLocation = "/${each.value.name}"
    skuName = "free"
    skuTier = "free"
    outputLocation = "/${each.value.name}"
    customDomain = "${each.value.custom_domain}"
    skipGitHubactionWorkflowGeneration = true
  }
}