DEPENDENCIES=$(cat <<EOD
  istio:
    git: https://github.com/vmware-allspark/istio
    branch: build-1.5.6
  cni:
    git: https://github.com/vmware-allspark/cni
    auto: deps
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
    branch: build-1.5.6
  gogo-genproto:
    git: https://github.com/vmware-allspark/gogo-genproto
    branch: build-1.5.6
  test-infra:
    git: https://github.com/vmware-allspark/test-infra
    branch: build-1.5.6
  tools:
    git: https://github.com/vmware-allspark/tools
    branch: build-1.5.6
EOD
)
