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

package publish

import (
	"fmt"
	"io/ioutil"
	"path"
	"path/filepath"
	"strings"

	"istio.io/pkg/log"
	"istio.io/release-builder/pkg/model"
	"istio.io/release-builder/pkg/util"
)

const DefaultVariant = "debug"

// Docker publishes all images to the given hub
func Docker(manifest model.Manifest, hub string, tags []string, cosignkey string) error {
	dockerArchives, err := ioutil.ReadDir(path.Join(manifest.Directory, "docker"))
	if err != nil {
		return fmt.Errorf("failed to read docker output of release: %v", err)
	}

	// Only attempt to sign images if a valid cosign key is provided and we are
	// able to run 'cosign public-key <key>'.
	cosignEnabled := false
	if cosignkey != "" {
		if err := util.VerboseCommand("cosign", "public-key", "--key", cosignkey).Run(); err != nil {
			log.Errorf("Argument '--cosignkey' nonempty but unable to access key %v, disabling signing.", err)
		} else {
			cosignEnabled = true
		}
	}

	for _, f := range dockerArchives {
		if !strings.HasSuffix(f.Name(), "tar.gz") {
			return fmt.Errorf("invalid image found in docker folder: %v", f.Name())
		}

		imageName, variant := getImageNameVariant(f.Name())
		if variant != "" {
			// Prepend - so it shows up as name-variant in the final tag
			variant = "-" + variant
		}
		if err := util.VerboseCommand("docker", "load", "-i", path.Join(manifest.Directory, "docker", f.Name())).Run(); err != nil {
			return fmt.Errorf("failed to load docker image %v: %v", f.Name(), err)
		}

		// Images are always built with the `istio` hub initially. We will retag these to the correct hub
		currentTag := fmt.Sprintf("%s/%s:%s%s", manifest.Docker, imageName, manifest.Version, variant)
		if len(tags) == 0 {
			tags = []string{manifest.Version}
		}
		variants := []string{variant}
		// Publish with no variant tag as well (ie "istio/pilot:tag")
		if variant == DefaultVariant {
			variants = append(variants, "")
		}
		for _, tag := range tags {
			for _, variant := range variants {
				newTag := fmt.Sprintf("%s/%s:%s%s", hub, imageName, tag, variant)
				if err := util.VerboseCommand("docker", "tag", currentTag, newTag).Run(); err != nil {
					return fmt.Errorf("failed to load docker image %v: %v", currentTag, err)
				}

				if err := util.VerboseCommand("docker", "push", newTag).Run(); err != nil {
					return fmt.Errorf("failed to push docker image %v: %v", newTag, err)
				}

				// Sign images *after* push -- cosign only works against real
				// repositories (not valid against tarballs)
				if cosignEnabled {
					if err := util.VerboseCommand("cosign", "sign", "--key", cosignkey, newTag).Run(); err != nil {
						return fmt.Errorf("failed to sign image %v with key %v: %v", newTag, cosignkey, err)
					}
				}
			}
		}
	}
	return nil
}

// getImageNameVariant determines the name of the image (eg, pilot) and variant (eg, distroless).
// This is derived from the file name.
func getImageNameVariant(fname string) (string, string) {
	imageName := strings.Split(fname, ".")[0]
	if match, _ := filepath.Match("*-distroless", imageName); match {
		return strings.TrimSuffix(imageName, "-distroless"), "distroless"
	}
	if match, _ := filepath.Match("*-debug", imageName); match {
		return strings.TrimSuffix(imageName, "-debug"), "debug"
	}
	return imageName, ""
}
