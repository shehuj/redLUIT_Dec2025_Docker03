# Docker Swarm Deployment with Ansible

Automated Docker Swarm cluster provisioning and deployment using Ansible playbooks and GitHub Actions CI/CD.

## Overview

This project automates the setup and management of a Docker Swarm cluster across multiple nodes using Ansible. It includes automated provisioning, swarm initialization, and application stack deployment through GitHub Actions workflows.

## Features

- 🚀 Automated Docker installation and configuration
- 🔧 Docker Swarm cluster initialization
- 📦 Stack deployment with Docker Compose files
- ✅ CI/CD integration with GitHub Actions
- 🧪 Automated testing with pytest and flake8
- 📝 Infrastructure as Code using Ansible

## Prerequisites

- **Control Machine**: Ansible 2.9+ installed
- **Target Nodes**:
  - CentOS/RHEL 7+ or compatible Linux distribution
  - SSH access configured
  - Sudo privileges
  - Minimum 2GB RAM, 20GB disk space per node
- **GitHub**: Repository with Actions enabled
- **Secrets**: `SSH_PRIVATE_KEY` configured in GitHub repository secrets

## Project Structure

```
ansible/
├── inventory/
│   ├── hosts.yml              # Inventory of manager and worker nodes
│   └── group_vars/
│       ├── all.yml            # Common variables for all hosts
│       ├── managers.yml       # Manager-specific variables
│       └── workers.yml        # Worker-specific variables
├── playbooks/
│   ├── 01-provision.yml       # Install Docker on all nodes
│   ├── 02-docker-swarm.yml    # Initialize Docker Swarm cluster
│   └── 03-deploy-stack.yml    # Deploy application stack
├── roles/
│   ├── docker/                # Docker installation role
│   │   └── tasks/main.yml
│   ├── swarm/                 # Swarm initialization role
│   │   └── tasks/main.yml
│   └── stack/                 # Stack deployment role
│       ├── tasks/main.yml
│       └── stacks/
│           └── docker-stack.yml
└── requirements.yml           # Ansible collection dependencies
```

## Quick Start

### 1. Configure Inventory

Edit `ansible/inventory/hosts.yml` with your server IPs:

```yaml
all:
  hosts:
    manager1:
      ansible_host: 192.168.1.10
    worker1:
      ansible_host: 192.168.1.11
    worker2:
      ansible_host: 192.168.1.12
```

### 2. Install Ansible Dependencies

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

### 3. Run Playbooks Manually

```bash
# Step 1: Install Docker on all nodes
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/01-provision.yml

# Step 2: Initialize Docker Swarm
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/02-docker-swarm.yml

# Step 3: Deploy application stack
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/03-deploy-stack.yml
```

## GitHub Actions Workflows

### Deploy to Swarm Workflow

Automatically triggers on push to `main` branch:

- ✅ Installs Ansible and dependencies
- ✅ Sets up SSH authentication
- ✅ Provisions Docker on all nodes
- ✅ Initializes Docker Swarm cluster
- ✅ Deploys application stack

**Workflow file**: `.github/workflows/deploy.yml`

### Python Application Workflow

Runs on push and pull requests:

- ✅ Lints code with flake8
- ✅ Runs tests with pytest

**Workflow file**: `.github/workflows/python-app.yml`

## Configuration

### Docker Stack

Customize your application stack in `ansible/roles/stack/stacks/docker-stack.yml`.

Default stack includes:
- **Web**: Nginx web server (2 replicas)
- **Visualizer**: Docker Swarm visualizer UI

### Variables

- **all.yml**: Common settings (ansible_user, docker_version)
- **managers.yml**: Manager node settings (stack_name: jenkinsstack)
- **workers.yml**: Worker node settings (resource_limits)

## Deployment

### Manual Deployment

```bash
# Deploy entire infrastructure
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/*.yml
```

### Automated Deployment

Push to `main` branch to trigger automatic deployment:

```bash
git add .
git commit -m "Deploy updates"
git push origin main
```

## Monitoring

Access the Docker Swarm Visualizer:
```
http://<manager-ip>:8080
```

View running services:
```bash
docker service ls
```

Check service logs:
```bash
docker service logs <service-name>
```

## Troubleshooting

### SSH Connection Issues

**Error**: `Permission denied (publickey)`

This means Ansible cannot authenticate to your servers. See the complete [SSH Setup Guide](SSH_SETUP.md) for detailed instructions.

**Quick fix**:
1. Verify correct username in `ansible/inventory/group_vars/all.yml` (default: `ec2-user`)
2. Add your SSH public key to all remote servers' `~/.ssh/authorized_keys`
3. Add the private key to GitHub Secrets as `SSH_PRIVATE_KEY`

For detailed step-by-step instructions, see **[SSH_SETUP.md](SSH_SETUP.md)**

### Docker Installation Fails

Check firewall settings:
```bash
sudo firewall-cmd --permanent --add-port=2377/tcp
sudo firewall-cmd --permanent --add-port=7946/tcp
sudo firewall-cmd --permanent --add-port=4789/udp
sudo firewall-cmd --reload
```

### Swarm Join Token Issues

Re-generate join token on manager:
```bash
docker swarm join-token worker
```

## Testing

Run tests locally:

```bash
# Install test dependencies
pip install -r requirements.txt

# Run linting
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics

# Run tests
pytest tests/
```

## Security Notes

- Never commit SSH private keys to the repository
- Use GitHub Secrets for sensitive data
- Regularly update Docker and system packages
- Implement firewall rules on production systems

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## License

MIT License - See [LICENSE](LICENSE) file for details

## Support

For issues and questions:
- Check existing GitHub Issues
- Review Ansible documentation
- Consult Docker Swarm documentation

---

**Last Updated**: December 2025
**Maintained by**: redLUIT Team
