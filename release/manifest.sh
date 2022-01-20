DEPENDENCIES=$(cat <<EOD
  istio:
    git: https://github.com/vmware-allspark/istio
    branch: build-1.12.2-telemetry-v2-test
  api:
    git: https://github.com/vmware-allspark/api
    auto: modules
  proxy:
    git: https://github.com/vmware-allspark/proxy
    auto: deps
  pkg:
    git: https://github.com/vmware-allspark/pkg
    auto: modules
  client-go:
    git: https://github.com/vmware-allspark/client-go
    branch: build-1.12.2-telemetry-v2-test
    goversionenabled: true
  gogo-genproto:
    git: https://github.com/vmware-allspark/gogo-genproto
    branch: build-1.12.2-telemetry-v2-test
  test-infra:
    git: https://github.com/vmware-allspark/test-infra
    branch: build-1.12.2-telemetry-v2-test
  tools:
    git: https://github.com/vmware-allspark/tools
    branch: build-1.12.2-telemetry-v2-test
EOD
)
