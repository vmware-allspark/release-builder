// Copyright Istio Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package build

import (
	"fmt"
	"path"
	"strings"

	"istio.io/release-builder/pkg/model"
	"istio.io/release-builder/pkg/util"
)

// Debian produces a debian package just for the sidecar
func Debian(manifest model.Manifest) error {
	for _, plat := range manifest.Architectures {
		_, arch, _ := strings.Cut(plat, "/")
		envs := []string{"TARGET_ARCH=" + arch}
		output := "istio-sidecar.deb"
		if arch != "amd64" {
			output = fmt.Sprintf("istio-sidecar-%s.deb", arch)
		}

		if err := runDeb(manifest, envs, arch, output); err != nil {
			return fmt.Errorf("failed to run deb for arch %s: %v", arch, err)
		}
	}

	return nil
}

func runDeb(manifest model.Manifest, envs []string, arch, output string) error {
	if err := util.RunMake(manifest, "istio", envs, "deb/fpm"); err != nil {
		return fmt.Errorf("failed to build sidecar.deb: %v", err)
	}

	if err := util.CopyFile(path.Join(manifest.RepoArchOutDir("istio", arch), "istio-sidecar.deb"), path.Join(manifest.OutDir(), "deb", output)); err != nil {
		return fmt.Errorf("failed to package istio-sidecar.deb: %v", err)
	}
	if err := util.CreateSha(path.Join(manifest.OutDir(), "deb", output)); err != nil {
		return fmt.Errorf("failed to package istio-sidecar.deb: %v", err)
	}
	return nil
}
