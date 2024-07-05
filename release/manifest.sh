DEPENDENCIES=$(cat <<EOD
  istio:
    git: https://github.com/vmware-allspark/istio
    branch: build-1.22.2-release-v1
  api:
    git: https://github.com/vmware-allspark/api
    auto: modules
  proxy:
    git: https://github.com/vmware-allspark/proxy
    auto: deps
  client-go:
    git: https://github.com/vmware-allspark/client-go
    branch: build-1.22.2-release-v1
    goversionenabled: true
  gogo-genproto:
    git: https://github.com/vmware-allspark/gogo-genproto
    branch: build-1.22.2-release-v1
  test-infra:
    git: https://github.com/vmware-allspark/test-infra
    branch: build-1.22.2-release-v1
  tools:
    git: https://github.com/vmware-allspark/tools
    branch: build-1.22.2-release-v1
  envoy:
    git: https://github.com/vmware-allspark/envoy
    auto: proxy_workspace
EOD
)
