// GITHUB_REF is the actual ref that triggers the workflow
// https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
variable "GITHUB_REF" {
  default = ""
}

target "_common" {
  args = {
    GIT_REF = GITHUB_REF
  }
}

group "default" {
  targets = ["image-local"]
}

// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {
  tags = ["registry:local"]
}

group "validate" {
  targets = ["validate-vendor"]
}

target "validate-vendor" {
  dockerfile = "./dockerfiles/vendor.Dockerfile"
  target = "validate"
  output = ["type=cacheonly"]
}

target "update-vendor" {
  dockerfile = "./dockerfiles/vendor.Dockerfile"
  target = "update"
  output = ["."]
}

target "mod-outdated" {
  dockerfile = "./dockerfiles/vendor.Dockerfile"
  target = "outdated"
  args = {
    // used to invalidate cache for outdated run stage
    // can be dropped when https://github.com/moby/buildkit/issues/1213 fixed
    _RANDOM = uuidv4()
  }
  output = ["type=cacheonly"]
}

target "binary" {
  inherits = ["_common"]
  target = "binary"
  output = ["./bin"]
}

target "artifact" {
  inherits = ["_common"]
  target = "artifact"
  output = ["./bin"]
}

target "artifact-all" {
  inherits = ["artifact"]
  platforms = [
    "linux/amd64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/arm64",
    "linux/ppc64le",
    "linux/s390x"
  ]
}

target "image" {
  inherits = ["_common", "docker-metadata-action"]
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/arm64",
    "linux/ppc64le",
    "linux/s390x"
  ]
}
