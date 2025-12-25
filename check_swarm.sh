#!/bin/bash
# Diagnostic script to check Docker Swarm status

echo "========================================="
echo "Checking Docker Swarm Nodes"
echo "========================================="
ssh -o StrictHostKeyChecking=no ec2-user@54.173.107.232 'docker node ls'

echo ""
echo "========================================="
echo "Checking Running Services"
echo "========================================="
ssh -o StrictHostKeyChecking=no ec2-user@54.173.107.232 'docker service ls'

echo ""
echo "========================================="
echo "Checking Web Service Placement"
echo "========================================="
ssh -o StrictHostKeyChecking=no ec2-user@54.173.107.232 'docker service ps jenkinsstack_web'

echo ""
echo "========================================="
echo "Checking All Stack Services"
echo "========================================="
ssh -o StrictHostKeyChecking=no ec2-user@54.173.107.232 'docker stack ps jenkinsstack'

echo ""
echo "========================================="
echo "Checking Worker1 Docker Status"
echo "========================================="
ssh -o StrictHostKeyChecking=no ec2-user@3.227.243.134 'docker info | grep -E "Swarm|NodeID"'

echo ""
echo "========================================="
echo "Checking Worker2 Docker Status"
echo "========================================="
ssh -o StrictHostKeyChecking=no ec2-user@44.198.170.154 'docker info | grep -E "Swarm|NodeID"'
