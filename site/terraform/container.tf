locals {
    dockerfile_path = abspath("${path.module}/..")
    container_tag = "gcr.io/${var.GOOGLE_CLOUD_PROJECT_ID}/${var.MODULE_SITE_CONTAINER_NAME}:${var.MODULE_SITE_CONTAINER_VERSION}"
}

resource "null_resource" "build_container" {
    triggers = tomap({"container_tag" = local.container_tag})
    provisioner "local-exec" {
        command = format("cd %s && make build-container-tf CONTAINER_TAG=%s", local.dockerfile_path, local.container_tag)
    }
}

resource "null_resource" "publish_container" {
    triggers = tomap({"container_tag" = local.container_tag})
    provisioner "local-exec" {
        command = format("cd %s && make publish-container-tf CONTAINER_TAG=%s", local.dockerfile_path, local.container_tag)
    }

    depends_on = [
        null_resource.build_container
    ]
}

resource "time_sleep" "wait_container_publish" {
    create_duration = "90s"

    depends_on = [
        null_resource.publish_container
    ]
}