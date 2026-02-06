# GitHub Actions Workflows

## Build and Push Docker Images

This workflow automatically builds and pushes Docker images to GitHub Container Registry (GHCR) when code is pushed to the `main` branch or when version tags are created.

### Triggers

- **Push to main branch**: Builds and tags as `latest`
- **Version tags** (e.g., `v1.0.0`): Builds with semantic versioning tags

### Required Secrets

You need to configure the following secrets in your GitHub repository settings:

1. **`GITHUB_TOKEN`** (automatically provided by GitHub)
   - Used to authenticate with GitHub Container Registry
   - No manual setup required

2. **`INFRA_REPO_TOKEN`** (required for deployment trigger)
   - Personal Access Token (PAT) with `repo` scope
   - Used to trigger deployment in infrastructure repository
   - Create at: https://github.com/settings/tokens

3. **`INFRA_REPO_OWNER`** (required)
   - GitHub username or organization that owns the infrastructure repo
   - Example: `your-username` or `your-org`

4. **`INFRA_REPO_NAME`** (required)
   - Name of your infrastructure repository
   - Example: `amar-pathagar-infra`

### Setup Instructions

1. **Enable GitHub Container Registry**
   ```bash
   # Make sure your repository has packages enabled
   # Go to: Settings > Actions > General > Workflow permissions
   # Enable: "Read and write permissions"
   ```

2. **Add Required Secrets**
   ```bash
   # Go to: Settings > Secrets and variables > Actions > New repository secret
   
   # Add INFRA_REPO_TOKEN
   # - Name: INFRA_REPO_TOKEN
   # - Value: Your GitHub Personal Access Token
   
   # Add INFRA_REPO_OWNER
   # - Name: INFRA_REPO_OWNER
   # - Value: your-github-username
   
   # Add INFRA_REPO_NAME
   # - Name: INFRA_REPO_NAME
   # - Value: amar-pathagar-infra
   ```

3. **Create a Personal Access Token**
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes: `repo` (full control of private repositories)
   - Copy the token and add it as `INFRA_REPO_TOKEN` secret

### Workflow Steps

1. **Checkout code**: Clones the repository
2. **Set up Docker Buildx**: Enables advanced Docker build features
3. **Login to GHCR**: Authenticates with GitHub Container Registry
4. **Extract metadata**: Generates Docker tags and labels
5. **Build and push**: Builds multi-platform images (amd64, arm64) and pushes to GHCR
6. **Trigger deployment**: Sends webhook to infrastructure repo for staging deployment

### Image Tags

The workflow creates the following tags:

- `latest` - Latest build from main branch
- `main-<sha>` - Commit SHA from main branch
- `v1.0.0` - Semantic version (when tagged)
- `1.0` - Major.minor version (when tagged)

### Usage

**Push to main branch:**
```bash
git add .
git commit -m "feat: add new feature"
git push origin main
```

**Create version tag:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Pulling Images

```bash
# Pull latest image
docker pull ghcr.io/your-username/amar-pathagar-backend:latest

# Pull specific version
docker pull ghcr.io/your-username/amar-pathagar-backend:v1.0.0
```

### Troubleshooting

**Error: "Resource not accessible by integration"**
- Go to Settings > Actions > General > Workflow permissions
- Enable "Read and write permissions"

**Error: "Failed to trigger deployment"**
- Check that `INFRA_REPO_TOKEN` has correct permissions
- Verify `INFRA_REPO_OWNER` and `INFRA_REPO_NAME` are correct
- Ensure the infrastructure repo exists and is accessible

**Build fails on arm64**
- This is normal if you don't need arm64 support
- Remove `linux/arm64` from platforms in the workflow file
