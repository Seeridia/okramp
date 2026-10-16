# Publish a website image to Tencent TCR

The website is built on GitHub Actions and published to Tencent TCR. Dokploy pulls the image and runs it on the deployment server.

## Repository settings

Under **Settings → Secrets and variables → Actions**, configure:

| Type     | Name             | OKRamp value                                   |
| -------- | ---------------- | ---------------------------------------------- |
| Variable | `TCR_NAMESPACE`  | `seeridia-static`                              |
| Variable | `TCR_REPOSITORY` | `okramp`                                       |
| Secret   | `TCR_USERNAME`   | Tencent TCR personal edition login username    |
| Secret   | `TCR_PASSWORD`   | Tencent TCR personal edition registry password |

The resulting image reference is `ccr.ccs.tencentyun.com/<TCR_NAMESPACE>/<TCR_REPOSITORY>:sha-<commit SHA>`.

## Publish and deploy

1. Open **Actions → Build image to Tencent TCR → Run workflow** and select the repository's default branch.
2. Wait for **Build and load image**, then **Push image to Tencent TCR** to succeed. The separate Docker push step shows layer progress and has a 10-minute timeout. Copy the image reference and registry digest from the run summary.
3. In Dokploy, open the website application and select the **Docker** provider. Set its Docker Image to that reference, Registry URL to `ccr.ccs.tencentyun.com`, and supply the registry login credentials.
4. Save and deploy manually. Verify the preview domain before switching production traffic.

The workflow currently runs manually and does not trigger Dokploy or change DNS/ESA. Keep previous successful image versions available for rollback; TCR personal edition limits each repository to 100 versions.

## Reuse for another website

Copy `.github/workflows/publish-tcr.yml` into the target repository and configure its variables and secrets. A root-level `Dockerfile` must build that website and serve its output; adjust the Dockerfile for the target site's package manager, build command, and output directory. The workflow uses the repository's default branch and builds `linux/amd64` images.

`ci.yml` continues to check and test OKRamp, and `publish.yml` continues to publish the npm package. The previous SSH deployment workflow to Hangzhou has been removed.
