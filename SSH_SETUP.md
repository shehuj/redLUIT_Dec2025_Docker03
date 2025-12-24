# SSH Setup Guide for GitHub Actions

This guide helps you configure SSH access for Ansible to connect to your remote servers.

## The Problem

The error `Permission denied (publickey,gssapi-keyex,gssapi-with-mic)` means Ansible cannot authenticate to your servers.

## Solution Steps

### 1. Verify the Correct Username

Your servers need to use the correct SSH username. Update `ansible/inventory/group_vars/all.yml`:

**For Amazon Linux / RHEL on EC2**:
```yaml
ansible_user: ec2-user
```

**For Ubuntu on EC2**:
```yaml
ansible_user: ubuntu
```

**For CentOS**:
```yaml
ansible_user: centos
```

**For Debian**:
```yaml
ansible_user: admin
```

### 2. Add Your SSH Public Key to Remote Servers

The SSH private key in your GitHub secret `SSH_PRIVATE_KEY` must have its public key added to **all remote servers**.

#### Option A: Manual Setup (Recommended for Testing)

On **each remote server**, run:

```bash
# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add your public key to authorized_keys
cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABA... your-public-key-here
EOF

# Set correct permissions
chmod 600 ~/.ssh/authorized_keys
```

#### Option B: AWS EC2 Key Pair Method

If using AWS EC2 instances:

1. **When launching instances**: Select or create an EC2 key pair
2. **Download the private key** (e.g., `my-keypair.pem`)
3. **Add to GitHub Secrets**:
   ```bash
   # View the private key content
   cat my-keypair.pem

   # Copy the entire output and add to GitHub Secrets as SSH_PRIVATE_KEY
   ```

### 3. Configure GitHub Secret

Add your SSH private key to GitHub repository secrets:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `SSH_PRIVATE_KEY`
5. Value: Paste your **entire private key** (including the header and footer):
   ```
   -----BEGIN RSA PRIVATE KEY-----
   MIIEpAIBAAKCAQEA...
   ...
   -----END RSA PRIVATE KEY-----
   ```
6. Click **Add secret**

### 4. Test SSH Connection Locally

Before running the GitHub Actions workflow, test SSH connection from your local machine:

```bash
# Test connection to your manager node
ssh -i /path/to/your-private-key ec2-user@35.170.80.190

# If successful, test Ansible ping
cd ansible
ansible all -m ping
```

Expected output:
```
manager1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 5. Verify Inventory Configuration

Check that `ansible/inventory/hosts.yml` has the correct IP addresses:

```yaml
all:
  hosts:
    manager1:
      ansible_host: 35.170.80.190  # Your actual manager IP
    worker1:
      ansible_host: 34.200.217.88  # Your actual worker IP
    worker2:
      ansible_host: 35.170.80.190  # Your actual worker IP
```

## Common Issues

### Issue 1: Wrong Username

**Error**: `Permission denied`

**Solution**: Update `ansible_user` in `ansible/inventory/group_vars/all.yml` to match your OS

### Issue 2: Public Key Not on Server

**Error**: `Permission denied (publickey)`

**Solution**: Add your public key to `~/.ssh/authorized_keys` on all servers (see Step 2 above)

### Issue 3: Wrong Private Key in GitHub Secret

**Error**: `Permission denied`

**Solution**: Ensure the private key in GitHub secrets matches the public key on your servers

### Issue 4: File Permissions on Remote Server

**Error**: SSH works manually but fails in automation

**Solution**: Fix permissions on remote servers:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Issue 5: Security Groups / Firewall Blocking SSH

**Error**: `Connection timed out` or `No route to host`

**Solution**:
- **AWS EC2**: Ensure security group allows SSH (port 22) from GitHub Actions IPs
- **Firewall**: Allow SSH traffic:
  ```bash
  sudo firewall-cmd --permanent --add-service=ssh
  sudo firewall-cmd --reload
  ```

## Quick Debugging

Run these commands to debug SSH issues:

```bash
# Test SSH with verbose output
ssh -vvv -i /path/to/key ec2-user@35.170.80.190

# Check if SSH agent has the key (in GitHub Actions)
ssh-add -l

# Test Ansible connection
ansible all -m ping -vvv
```

## AWS EC2 Specific: Using Session Manager (Alternative)

If you can't use SSH keys, consider AWS Systems Manager Session Manager:

1. Install AWS CLI and Session Manager plugin
2. Use `aws ssm start-session` instead of SSH
3. Configure Ansible to use Session Manager as connection method

## Verification Checklist

Before running the workflow, verify:

- [ ] SSH private key is in GitHub Secrets as `SSH_PRIVATE_KEY`
- [ ] Public key is in `~/.ssh/authorized_keys` on all remote servers
- [ ] `ansible_user` in `all.yml` matches your server's default user
- [ ] IP addresses in `hosts.yml` are correct
- [ ] Security groups/firewall allow SSH (port 22)
- [ ] Remote servers are running and accessible
- [ ] SSH key permissions are correct (600 for private key, 644 for public key)

## Still Having Issues?

1. Check GitHub Actions logs for detailed error messages
2. Test SSH connection manually from your local machine
3. Verify the key fingerprint matches:
   ```bash
   ssh-keygen -lf /path/to/private-key
   ssh-keygen -lf ~/.ssh/authorized_keys
   ```
4. Ensure no SELinux restrictions (on RHEL/CentOS):
   ```bash
   sudo setenforce 0  # Temporarily disable for testing
   ```

---

**Need more help?** Check the main [README.md](README.md) troubleshooting section.
