# GitHub Secrets Setup Guide

This guide helps you configure the required GitHub secrets for CI/CD workflows.

## Required Secrets

### Staging Environment

Navigate to: `Settings → Secrets and variables → Actions → New repository secret`

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `STAGING_DB_HOST` | PostgreSQL host for staging | `staging-db.example.com` |
| `STAGING_DB_PORT` | PostgreSQL port | `5432` |
| `STAGING_DB_NAME` | Database name | `chat_staging` |
| `STAGING_DB_USER` | Database user | `chat_user` |
| `STAGING_DB_PASSWORD` | Database password | `<secure-password>` |
| `STAGING_SERVERPOD_HOST` | Serverpod API host | `api-staging.example.com` |
| `STAGING_SERVERPOD_PORT` | Serverpod API port | `8080` |
| `FIREBASE_APP_ID_STAGING` | Firebase App ID for staging | `1:123456789:android:abc123` |
| `FIREBASE_TOKEN` | Firebase CLI token | `<firebase-token>` |

### Production Environment

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `PROD_DB_HOST` | PostgreSQL host for production | `prod-db.example.com` |
| `PROD_DB_PORT` | PostgreSQL port | `5432` |
| `PROD_DB_NAME` | Database name | `chat_production` |
| `PROD_DB_USER` | Database user | `chat_user` |
| `PROD_DB_PASSWORD` | Database password | `<secure-password>` |
| `PROD_SERVERPOD_HOST` | Serverpod API host | `api.example.com` |
| `PROD_SERVERPOD_PORT` | Serverpod API port | `443` |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | Google Play service account JSON | `{"type": "service_account", ...}` |

## How to Obtain Secret Values

### Database Credentials

**For managed PostgreSQL (AWS RDS, Google Cloud SQL, etc.):**
1. Create a database instance in your cloud provider
2. Note the endpoint/host, port, database name
3. Create a database user with appropriate permissions
4. Store credentials securely

**For self-hosted PostgreSQL:**
1. Install PostgreSQL on your server
2. Create database: `CREATE DATABASE chat_staging;`
3. Create user: `CREATE USER chat_user WITH PASSWORD 'password';`
4. Grant permissions: `GRANT ALL PRIVILEGES ON DATABASE chat_staging TO chat_user;`

### Serverpod Configuration

**Host and Port:**
- Staging: Your staging server domain/IP and port
- Production: Your production server domain/IP and port (typically 443 for HTTPS)

Example:
```
STAGING_SERVERPOD_HOST=staging-api.yourapp.com
STAGING_SERVERPOD_PORT=8080
PROD_SERVERPOD_HOST=api.yourapp.com
PROD_SERVERPOD_PORT=443
```

### Firebase Credentials

**Firebase Token (for App Distribution):**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and get token
firebase login:ci

# Copy the token and add it as FIREBASE_TOKEN secret
```

**Firebase App ID:**
1. Go to Firebase Console → Project Settings
2. Select your app (Android/iOS)
3. Copy the App ID (format: `1:123456789:android:abc123def456`)
4. Add as `FIREBASE_APP_ID_STAGING` secret

### Google Play Service Account

**For Google Play Store deployment:**

1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to: Setup → API access
3. Create a new service account or use existing
4. Download the JSON key file
5. Copy the entire JSON content
6. Add as `GOOGLE_PLAY_SERVICE_ACCOUNT` secret

Example JSON structure:
```json
{
  "type": "service_account",
  "project_id": "your-project",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "...",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

## Security Best Practices

### 1. Use Strong Passwords
```bash
# Generate secure password
openssl rand -base64 32
```

### 2. Rotate Credentials Regularly
- Database passwords: Every 90 days
- Service account keys: Every 180 days
- API tokens: When compromised or annually

### 3. Limit Permissions
- Database users: Grant only necessary permissions
- Service accounts: Use principle of least privilege
- API tokens: Scope to specific operations

### 4. Use Environment Protection Rules

For production secrets, enable environment protection:

1. Go to: `Settings → Environments → New environment`
2. Create "production" environment
3. Add protection rules:
   - Required reviewers (at least 1)
   - Wait timer (optional)
   - Deployment branches (only `main`)

### 5. Audit Secret Access
- Review GitHub Actions logs regularly
- Monitor database access logs
- Set up alerts for unusual activity

## Verification

After adding secrets, verify they work:

### Test Staging Deployment
```bash
# Trigger staging deployment
git checkout develop
git commit --allow-empty -m "Test staging deployment"
git push origin develop

# Check GitHub Actions tab for workflow status
```

### Test Production Deployment
```bash
# Create a release tag
git checkout main
git tag v1.0.0
git push origin v1.0.0

# Check GitHub Actions tab for workflow status
```

## Troubleshooting

### Secret not found error
- Verify secret name matches exactly (case-sensitive)
- Check secret is added to correct repository
- Ensure workflow has access to secrets

### Database connection failed
- Verify host, port, database name
- Check firewall rules allow GitHub Actions IPs
- Test credentials manually:
  ```bash
  psql -h $HOST -p $PORT -U $USER -d $DATABASE
  ```

### Firebase deployment failed
- Verify Firebase token is valid: `firebase login:ci`
- Check App ID format is correct
- Ensure Firebase App Distribution is enabled

### Google Play deployment failed
- Verify service account JSON is valid
- Check service account has "Release Manager" role
- Ensure app is registered in Play Console

## Secret Rotation Procedure

When rotating secrets:

1. **Create new credentials** (don't delete old ones yet)
2. **Update GitHub secrets** with new values
3. **Test deployment** to verify new credentials work
4. **Revoke old credentials** after successful test
5. **Document rotation** in your security log

## Additional Resources

- [GitHub Actions Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)
- [Google Play Console API](https://developers.google.com/android-publisher)
- [PostgreSQL Security Best Practices](https://www.postgresql.org/docs/current/auth-methods.html)
