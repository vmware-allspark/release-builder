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
	"os"
	"path"
	"strings"

	"github.com/spf13/cobra"

	"istio.io/pkg/log"
	"istio.io/release-builder/pkg"
	"istio.io/release-builder/pkg/model"
	"istio.io/release-builder/pkg/util"
)

var (
	flags = struct {
		release      string
		dockerhub    string
		dockertags   []string
		gcsbucket    string
		gcsaliases   []string
		github       string
		githubtoken  string
		grafanatoken string
	}{}
	publishCmd = &cobra.Command{
		Use:          "publish",
		Short:        "Publish a release of Istio",
		SilenceUsage: true,
		Args:         cobra.ExactArgs(0),
		RunE: func(c *cobra.Command, _ []string) error {
			if err := validateFlags(); err != nil {
				return fmt.Errorf("invalid flags: %v", err)
			}

			log.Infof("Publishing Istio release from: %v", flags.release)

			manifest, err := pkg.ReadManifest(path.Join(flags.release, "manifest.yaml"))
			if err != nil {
				return fmt.Errorf("failed to read manifest from release: %v", err)
			}
			manifest.Directory = path.Join(flags.release)
			util.YamlLog("Manifest", manifest)

			return Publish(manifest)
		},
	}
)

func init() {
	publishCmd.PersistentFlags().StringVar(&flags.release, "release", flags.release,
		"The directory with the Istio release binary.")
	publishCmd.PersistentFlags().StringVar(&flags.dockerhub, "dockerhub", flags.dockerhub,
		"The docker hub to push images to. Example: docker.io/istio.")
	publishCmd.PersistentFlags().StringSliceVar(&flags.dockertags, "dockertags", flags.dockertags,
		"The tags to apply to docker images. Example: latest")
	publishCmd.PersistentFlags().StringVar(&flags.gcsbucket, "gcsbucket", flags.gcsbucket,
		"The gcs bucket to publish binaries to. Example: gs://istio-release.")
	publishCmd.PersistentFlags().StringSliceVar(&flags.gcsaliases, "gcsaliases", flags.gcsaliases,
		"Alias to publish to gcs. Example: latest")
	publishCmd.PersistentFlags().StringVar(&flags.github, "github", flags.github,
		"The Github org to trigger a release, and tag, for. Example: istio.")
	publishCmd.PersistentFlags().StringVar(&flags.githubtoken, "githubtoken", flags.githubtoken,
		"The file containing a github token.")
	publishCmd.PersistentFlags().StringVar(&flags.grafanatoken, "grafanatoken", flags.grafanatoken,
		"The file containing a grafana.com API token.")
}

func GetPublishCommand() *cobra.Command {
	return publishCmd
}

func validateFlags() error {
	if flags.release == "" {
		return fmt.Errorf("--release required")
	}
	return nil
}

func Publish(manifest model.Manifest) error {
	if flags.dockerhub != "" {
		if err := Docker(manifest, flags.dockerhub, flags.dockertags); err != nil {
			return fmt.Errorf("failed to publish to docker: %v", err)
		}
	}
	if flags.gcsbucket != "" {
		if err := GcsArchive(manifest, flags.gcsbucket, flags.gcsaliases); err != nil {
			return fmt.Errorf("failed to publish to gcs: %v", err)
		}
	}
	if flags.github != "" {
		token, err := util.GetGithubToken(flags.githubtoken)
		if err != nil {
			return err
		}
		if err := Github(manifest, flags.github, token); err != nil {
			return fmt.Errorf("failed to publish to github: %v", err)
		}
	}
	if flags.grafanatoken != "" {
		token, err := getGrafanaToken(flags.grafanatoken)
		if err != nil {
			return err
		}

		if err := Grafana(manifest, token); err != nil {
			return fmt.Errorf("failed to publish to github: %v", err)
		}
	}
	return nil
}

func getGrafanaToken(file string) (string, error) {
	if file != "" {
		b, err := ioutil.ReadFile(file)
		if err != nil {
			return "", fmt.Errorf("failed to read grafana token: %v", file)
		}
		return strings.TrimSpace(string(b)), nil
	}
	return os.Getenv("GRAFANA_TOKEN"), nil
}
