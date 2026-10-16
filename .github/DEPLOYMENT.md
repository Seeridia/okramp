# Publish a website image to Tencent TCR

The website is built on GitHub Actions and published to Tencent TCR. Dokploy pulls the image and runs it on the deployment server.

## Repository settings

Under **Settings → Secrets and variables → Actions**, configure:

| Type     | Name                  | OKRamp value                                   |
| -------- | --------------------- | ---------------------------------------------- |
| Variable | `TCR_NAMESPACE`       | `seeridia-static`                              |
| Variable | `TCR_REGISTRY`        | Optional; defaults to `ccr.ccs.tencentyun.com` |
| Variable | `TCR_REPOSITORY`      | `okramp`                                       |
| Secret   | `TCR_USERNAME`        | Tencent TCR personal edition login username    |
| Secret   | `TCR_PASSWORD`        | Tencent TCR personal edition registry password |
| Secret   | `DOKPLOY_WEBHOOK_URL` | Application → Deployments → Webhook URL        |

The workflow publishes the same image as `<TCR_REGISTRY>/<TCR_NAMESPACE>/<TCR_REPOSITORY>:latest` and `:sha-<commit SHA>`. For OKRamp, `TCR_REGISTRY` is `hkccr.ccs.tencentyun.com`. Regional registries are independent services.

This workflow uses the application's webhook URL and requires neither an application ID nor a Dokploy API key. Store the entire URL as a secret because its token authorizes deployment of that application.

## Publish and deploy

1. Configure the Dokploy application's **Docker** provider once: Docker Image must be `<TCR_REGISTRY>/<TCR_NAMESPACE>/<TCR_REPOSITORY>:latest`, with the selected registry hostname and credentials. Save it and enable **General → Auto Deploy**. Copy its webhook URL from **Deployments** into the repository secret. The workflow does not update these settings on every run.
2. Open **Actions → Build image to Tencent TCR → Run workflow** and select the repository's default branch.
3. The workflow builds and loads the image, pushes its SHA tag, pushes `latest`, and confirms both tags have the same digest. Only then does it POST to the webhook once. The request uses Dokploy's supported `registry_package` payload to validate the configured image name and `latest` tag and attach the commit hash to the deployment. Both HTTP status and the acknowledgement body are checked; redirects are not followed.
4. Check **Dokploy → OKRamp → Deployments** for deployment completion and verify the website. A successful workflow confirms that Dokploy accepted the request, not that deployment or health checks have completed.

The workflow runs manually; after a successful image push it triggers Dokploy automatically. It does not change DNS/ESA. Runs are serialized so this workflow does not overwrite `latest` concurrently. Keep previous successful SHA image tags for rollback; TCR personal edition limits each repository to 100 versions. To roll back, set the Dokploy image to the previous SHA tag and deploy; restore its image setting to `latest` before resuming automatic deployment.

For a small upload measurement, run **Measure Tencent TCR upload** with an optional `registry` input. This overrides the endpoint for that diagnostic run only and leaves the publishing configuration unchanged. The probe uploads one fresh 8 MiB layer and stops after 180 seconds if the push does not complete.

## Reuse for another website

Copy `.github/workflows/publish-tcr.yml` into the target repository and configure its variables and secrets. A root-level `Dockerfile` must build that website and serve its output; adjust the Dockerfile for the target site's package manager, build command, and output directory. The workflow uses the repository's default branch and builds `linux/amd64` images.

`ci.yml` continues to check and test OKRamp, and `publish.yml` continues to publish the npm package. The previous SSH deployment workflow to Hangzhou has been removed.
