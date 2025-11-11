# Smithery Credentials Configuration

This guide explains how to properly configure AWS credentials for use with Smithery.

## The Issue

When running `npx smithery dev`, the server needs AWS credentials to connect to DynamoDB. There are several ways to provide these credentials.

## Solution 1: Use the Helper Script (Recommended)

We've created a helper script that loads credentials from your `.env` file:

```bash
npm run smithery
```

This script:
1. Loads environment variables from `.env`
2. Passes them to Smithery
3. Starts the dev server

### Setup

1. Make sure your `.env` file has the correct variable names:

```bash
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY
```

**Important**: The variable must be `AWS_ACCESS_KEY_ID`, not `AWS_ACCESS_ID`!

2. Run the helper script:

```bash
npm run smithery
```



## Solution 3: Configure in Smithery UI

When you run `npx smithery dev`, Smithery will open a web interface. You can configure credentials there:

1. Open the Smithery web interface (usually http://localhost:8081)
2. Go to Settings or Configuration
3. Enter your AWS credentials:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_REGION

## Solution 4: Use AWS Credentials File

If you have AWS CLI configured, Smithery might automatically use those credentials:

```bash
# Check if AWS CLI is configured
aws configure list

# If not configured, set it up
aws configure
```

Then run:
```bash
npx smithery dev
```

## Verifying Credentials

### Check Environment Variables

**PowerShell:**
```powershell
echo $env:AWS_ACCESS_KEY_ID
echo $env:AWS_REGION
```

**Bash:**
```bash
echo $AWS_ACCESS_KEY_ID
echo $AWS_REGION
```

### Test with AWS CLI

```bash
aws dynamodb list-tables --region us-east-1
```

If this works, your credentials are valid.

## Common Issues

### Issue 1: "Resolved credential object is not valid"

**Cause**: Credentials are not set or have wrong variable names

**Solution**: 
1. Check `.env` file has `AWS_ACCESS_KEY_ID` (not `AWS_ACCESS_ID`)
2. Use `npm run smithery` instead of `npx smithery dev`
3. Or set environment variables manually before running

### Issue 2: Credentials in .env but still not working

**Cause**: Smithery doesn't automatically load `.env` files

**Solution**: Use our helper script:
```bash
npm run smithery
```

### Issue 3: "Access Denied" errors

**Cause**: IAM permissions are insufficient

**Solution**: Ensure your AWS user/role has these permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:ListTables",
        "dynamodb:UpdateTable",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "*"
    }
  ]
}
```

### Issue 4: Credentials work in standalone mode but not Smithery

**Cause**: Different credential loading mechanisms

**Solution**: 
1. Use `npm run smithery` which loads `.env` explicitly
2. Or configure credentials in Smithery UI
3. Or set environment variables before running Smithery

## How It Works

### Standalone Mode (`npm start`)
```
.env file → process.env → DynamoDB Client
```

### Smithery Mode (`npm run smithery`)
```
.env file → smithery-dev.js → process.env → Smithery → config parameter → process.env → DynamoDB Client
```

### Direct Smithery (`npx smithery dev`)
```
Smithery UI config → config parameter → process.env → DynamoDB Client
```

## Best Practices

### For Development

Use the helper script with `.env` file:
```bash
npm run smithery
```

### For Production

Use IAM roles instead of access keys:
- AWS EC2: Instance profile
- AWS ECS: Task role
- AWS Lambda: Execution role

### Security

1. **Never commit `.env` to git**
   - Already in `.gitignore`
   - Double-check before committing

2. **Use temporary credentials when possible**
   - AWS STS
   - IAM roles
   - Session tokens

3. **Rotate credentials regularly**
   - Set up automatic rotation
   - Use AWS Secrets Manager

4. **Limit permissions**
   - Only grant necessary DynamoDB permissions
   - Use resource-specific policies

## Quick Reference

| Method | Command | Pros | Cons |
|--------|---------|------|------|
| Helper Script | `npm run smithery` | Easy, loads .env | Requires dotenv package |
| Manual Env Vars | `export AWS_...` then `npx smithery dev` | No dependencies | Must set each time |
| Smithery UI | Configure in web interface | Persistent | Manual entry |
| AWS CLI Config | `aws configure` then `npx smithery dev` | Shared with AWS CLI | May not work with Smithery |

## Troubleshooting Steps

1. **Verify .env file format**
   ```bash
   cat .env
   # Should show AWS_ACCESS_KEY_ID (not AWS_ACCESS_ID)
   ```

2. **Test credentials with AWS CLI**
   ```bash
   aws dynamodb list-tables --region us-east-1
   ```

3. **Use helper script**
   ```bash
   npm run smithery
   ```

4. **Check Smithery logs**
   - Look for credential-related errors
   - Verify which credentials are being used

5. **Try manual environment variables**
   ```bash
   export AWS_ACCESS_KEY_ID="your_key"
   export AWS_SECRET_ACCESS_KEY="your_secret"
   export AWS_REGION="us-east-1"
   npx smithery dev
   ```

## Support

If you're still having issues:

1. Check that `.env` has correct variable names
2. Verify credentials work with AWS CLI
3. Use `npm run smithery` instead of direct Smithery
4. Check IAM permissions
5. Review Smithery logs for specific errors

## Summary

**The easiest way to run with Smithery:**

```bash
# 1. Fix .env file (use AWS_ACCESS_KEY_ID, not AWS_ACCESS_ID)
# 2. Run the helper script
npm run smithery
```

This will load your credentials from `.env` and start Smithery with proper configuration.
