#!/bin/bash
# Update all k3s nodes

ssh -t k3s-master "sudo apt update && sudo apt upgrade -y"
ssh -t k3s-worker-1 "sudo apt update && sudo apt upgrade -y"
