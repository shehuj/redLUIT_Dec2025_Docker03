# redLUIT_Dec2025_Docker03

ansible/
├── inventory/
│   ├── hosts.yml
│   └── group_vars/
│       ├── all.yml
│       ├── managers.yml
│       └── workers.yml
├── playbooks/
│   ├── 01-provision.yml
│   ├── 02-docker-swarm.yml
│   └── 03-deploy-stack.yml
├── roles/
│   ├── docker/
│   │   └── tasks/main.yml
│   ├── swarm/
│   │   └── tasks/main.yml
│   └── stack/
│       └── tasks/main.yml
└── requirements.yml