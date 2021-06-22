DEPENDENCIES=$(cat <<EOD
  istio:
    git: https://github.com/vmware-allspark/istio
    branch: build-build-1.9-mesh7-custom-envoy-v8
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
    branch: build-build-1.9-mesh7-custom-envoy-v8
    goversionenabled: true
  gogo-genproto:
    git: https://github.com/vmware-allspark/gogo-genproto
    branch: build-build-1.9-mesh7-custom-envoy-v8
  test-infra:
    git: https://github.com/vmware-allspark/test-infra
    branch: build-build-1.9-mesh7-custom-envoy-v8
  tools:
    git: https://github.com/vmware-allspark/tools
    branch: build-build-1.9-mesh7-custom-envoy-v8
  envoy:
    git: https://github.com/vmware-allspark/envoy
    auto: proxy_workspace
EOD
)
