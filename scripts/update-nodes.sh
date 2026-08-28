#!/bin/bash
# Update all nodes

ssh -t k3s-master "sudo apt update && sudo apt upgrade -y"
ssh -t k3s-worker-1 "sudo apt update && sudo apt upgrade -y"
ssh -t k3s-worker-2 "sudo apt update && sudo apt upgrade -y"
ssh -t srv-1 "sudo apt update && sudo apt upgrade -y"
