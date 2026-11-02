# docker-bake.hcl – Stand Ende Tag 15: alle drei notes-Images mit einem Befehl
variable "REG" {
  default = "registry.ct.lab:5000"
}

variable "VERSION" {
  default = "0.1.0"
}

group "default" {
  targets = ["api", "worker", "web"]
}

target "_common" {
  platforms = ["linux/amd64"]
  args      = { VERSION = VERSION }
}

target "api" {
  inherits  = ["_common"]
  context   = "notes-api"
  platforms = ["linux/amd64", "linux/arm64"]   # Go kompiliert quer, ohne QEMU
  tags     = ["${REG}/lab/notes-api:${VERSION}"]
}

target "worker" {
  inherits = ["_common"]
  context  = "notes-worker"
  tags     = ["${REG}/lab/notes-worker:${VERSION}"]
}

target "web" {
  inherits = ["_common"]
  context  = "notes-web"
  tags     = ["${REG}/lab/notes-web:${VERSION}"]
}
