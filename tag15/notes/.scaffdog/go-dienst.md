---
name: 'go-dienst'
root: '.'
output: '.'
questions:
  name: 'Name des Dienstes (z. B. notes-report)?'
  port:
    message: 'Port im Container?'
    initial: '8080'
---

# `{{ inputs.name }}/go.mod`

```text
module example.com/{{ inputs.name }}

go 1.27
```

# `{{ inputs.name }}/main.go`

```go
// {{ inputs.name }} – erzeugt mit scaffdog aus .scaffdog/go-dienst.md
package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, "ok")
	})
	http.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, "{{ inputs.name }} läuft")
	})
	log.Fatal(http.ListenAndServe(":{{ inputs.port }}", nil))
}
```

# `{{ inputs.name }}/Dockerfile`

```dockerfile
# syntax=docker/dockerfile:1
# {{ inputs.name }}/Dockerfile – erzeugt mit scaffdog, baut für jede Plattform quer
FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27-alpine AS build
ARG TARGETOS TARGETARCH
WORKDIR /src
COPY go.mod main.go ./
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w" -o /out/{{ inputs.name }} .

FROM scratch
COPY --from=build /out/{{ inputs.name }} /{{ inputs.name }}
EXPOSE {{ inputs.port }}
USER 65532:65532
ENTRYPOINT ["/{{ inputs.name }}"]
```

# `{{ inputs.name }}/.dockerignore`

```text
Dockerfile
.dockerignore
```
