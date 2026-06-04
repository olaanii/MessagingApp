# CI/CD Pipeline Documentation

This directory contains GitHub Actions workflows for continuous integration and deployment of the chat application.

## Workflows

### 1. Serverpod Backend CI (`dart.yml`)

**Triggers:**
- Push to `main` or `develop` branches (when server code changes)
- Pull requests to `main` or `develop` branches (when server code changes)

**What it does:**
- Sets up PostgreSQL test database
- Installs Serverpod CLI
- Generates Serverpod code from protocol definitions
- Verifies generated code is up to date
- Runs `dart analyze` on server and client code
- Runs `dart test` on server and client code

**Required secrets:** None (uses local PostgreSQL service)

### 2. Flutter CI (`flutter_ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches (when Flutter code changes)
- Pull requests to `main` or `develop` branches (when Flutter code changes)

**What it does:**
- Installs Serverpod CLI
- Generates Serverpod client code
- Verifies generated code is up to date
- Runs `flutter analyze` with fatal infos
- Runs `flutter test` with coverage
- Uploads coverage to Codecov (optional)

**Required secrets:** None

### 3. Deploy Staging (`deploy_staging.yml`)

**Triggers:**
- Push to `develop` branch
- Manual workflow dispatch

**What it does:**
1. **Test Job:**
   - Runs all backend and frontend tests
   - Generates Serverpod code
   - Validates code quality

2. **Deploy Backend Job:**
   - Generates Serverpod code
   - Builds server binary
   - Applies database migrations to staging
   - Deploys backend to staging server (placeholder)

3. **Build App Job:**
   - Generates Serverpod client code
   - Builds Android APK with staging configuration
   - Uploads APK as artifact

4. **Deploy App Job:**
   - Downloads APK artifact
   - Deploys to staging distribution (placeholder)

**Required secrets:**
- `STAGING_DB_HOST` - Staging PostgreSQL host
- `STAGING_DB_PORT` - Staging PostgreSQL port
- `STAGING_DB_NAME` - Staging database name
- `STAGING_DB_USER` - Staging database user
- `STAGING_DB_PASSWORD` - Staging database password
- `STAGING_SERVERPOD_HOST` - Staging Serverpod API host
- `STAGING_SERVERPOD_PORT` - Staging Serverpod API port

### 4. Deploy Production (`deploy_production.yml`)

**Triggers:**
- Push to `main` branch
- Push tags matching `v*.*.*` pattern
- Manual workflow dispatch

**What it does:**
1. **Test Job:**
   - Runs comprehensive test suite
   - Validates production readiness

2. **Deploy Backend Job:**
   - Creates database backup before migration
   - Applies database migrations to production
   - Deploys backend with zero-downtime strategy (placeholder)

3. **Build Android Job:**
   - Builds Android App Bundle (AAB) for Play Store
   - Uploads AAB as artifact

4. **Build iOS Job:**
   - Builds iOS app for App Store
   - Prepares for TestFlight/App Store upload (placeholder)

5. **Deploy Android Job:**
   - Deploys to Google Play Store (placeholder)

6. **Deploy iOS Job:**
   - Deploys to App Store Connect (placeholder)

**Required secrets:**
- `PROD_DB_HOST` - Production PostgreSQL host
- `PROD_DB_PORT` - Production PostgreSQL port
- `PROD_DB_NAME` - Production database name
- `PROD_DB_USER` - Production database user
- `PROD_DB_PASSWORD` - Production database password
- `PROD_SERVERPOD_HOST` - Production Serverpod API host
- `PROD_SERVERPOD_PORT` - Production Serverpod API port
- `GOOGLE_PLAY_SERVICE_ACCOUNT` - Google Play service account JSON (for Play Store deployment)
- `FIREBASE_TOKEN` - Firebase token (for Firebase App Distribution)
- `FIREBASE_APP_ID_STAGING` - Firebase App ID for staging

## Setup Instructions

### 1. Configure GitHub Secrets

Go to your repository Settings → Secrets and variables → Actions, and add the required secrets listed above.

### 2. Database Migration Setup

The workflows automatically apply database migrations during deployment. Ensure your migration files are in:
```
server/chat_server/migrations/
```

The `apply_all.sql` script tracks applied migrations to prevent duplicate execution.

### 3. Customize Deployment Steps

The workflows contain placeholder deployment steps marked with `TODO`. Replace these with your actual deployment commands:

**For Serverpod backend:**
- SSH deployment: `scp` + `systemctl restart`
- Docker: Build and push to registry
- Kubernetes: `kubectl apply` or Helm
- Cloud Run: `gcloud run deploy`
- AWS ECS: `aws ecs update-service`

**For Flutter app:**
- Firebase App Distribution (staging)
- Google Play Store (production)
- App Store Connect (production)

### 4. Enable Codecov (Optional)

To enable code coverage reporting:
1. Sign up at [codecov.io](https://codecov.io)
2. Add your repository
3. No additional secrets needed (Codecov GitHub Action handles authentication)

## Code Generation

All workflows that build or test code include a `serverpod generate` step. This ensures:
- Protocol definitions are compiled to Dart code
- Client and server code are in sync
- Generated code is always up to date

The CI workflows will fail if generated code is out of sync with protocol definitions, prompting developers to run `serverpod generate` locally and commit changes.

## Migration Strategy

Database migrations are applied automatically during deployment:

1. **Staging:** Migrations run before backend deployment
2. **Production:** Database backup is created before migrations, then migrations are applied

Migration tracking prevents duplicate execution using the `schema_migrations` table.

## Workflow Dependencies

```
deploy_staging.yml:
  test → deploy_backend
  test → build_app → deploy_app

deploy_production.yml:
  test → deploy_backend
  test → build_android → deploy_android
  test → build_ios → deploy_ios
```

## Best Practices

1. **Always run tests before deployment** - The workflows enforce this
2. **Keep generated code in sync** - Run `serverpod generate` after protocol changes
3. **Use feature branches** - CI runs on all branches, but deployment only on `develop` and `main`
4. **Tag releases** - Use semantic versioning tags (v1.0.0) for production releases
5. **Monitor deployments** - Check GitHub Actions logs for deployment status
6. **Backup before migrations** - Production workflow creates automatic backups

## Troubleshooting

### Generated code out of sync
```bash
cd server
serverpod generate
git add .
git commit -m "Update generated code"
```

### Migration failures
- Check migration SQL syntax
- Verify database credentials in secrets
- Review migration tracking in `schema_migrations` table

### Build failures
- Ensure all dependencies are in pubspec.yaml
- Check Dart/Flutter SDK version compatibility
- Review error logs in GitHub Actions

## Local Testing

Test workflows locally before pushing:

```bash
# Test Serverpod backend
cd server
serverpod generate
cd chat_server
dart analyze
dart test

# Test Flutter app
cd chat
flutter analyze
flutter test
```
