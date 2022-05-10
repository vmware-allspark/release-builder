DEPENDENCIES=$(cat <<EOD
  istio:
    git: https://github.com/vmware-allspark/istio
    branch: build-1.12.7-release-tsm-enterprise
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
    branch: build-1.12.7-release-tsm-enterprise
    goversionenabled: true
  gogo-genproto:
    git: https://github.com/vmware-allspark/gogo-genproto
    branch: build-1.12.7-release-tsm-enterprise
  test-infra:
    git: https://github.com/vmware-allspark/test-infra
    branch: build-1.12.7-release-tsm-enterprise
  tools:
    git: https://github.com/vmware-allspark/tools
    branch: build-1.12.7-release-tsm-enterprise
  envoy:
    git: https://github.com/vmware-allspark/envoy
    auto: proxy_workspace
EOD
)
