ISTIO_ENVOY_BASE_URL=https://github.com/vmware-allspark/proxy/releases/download/1.7.8-custom
DEPENDENCIES=$(cat <<EOD
  istio:
    git: https://github.com/vmware-allspark/istio
    branch: build-1.7.8-custom
  api:
    git: https://github.com/vmware-allspark/api
    auto: modules
  proxy:
    git: https://github.com/vmware-allspark/proxy
    branch: build-1.7.8-custom
  pkg:
    git: https://github.com/vmware-allspark/pkg
    auto: modules
  client-go:
    git: https://github.com/vmware-allspark/client-go
    branch: build-1.7.8
    goversionenabled: true
  gogo-genproto:
    git: https://github.com/vmware-allspark/gogo-genproto
    branch: build-1.7.8
  test-infra:
    git: https://github.com/vmware-allspark/test-infra
    branch: build-1.7.8
  tools:
    git: https://github.com/vmware-allspark/tools
    branch: build-1.7.8
  envoy:
    git: https://github.com/vmware-allspark/envoy
    auto: proxy_workspace
EOD
)
