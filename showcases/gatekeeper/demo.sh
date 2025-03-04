#!/bin/bash

if ! command -v pv &> /dev/null; then
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y pv
    elif command -v yum &> /dev/null; then
        sudo yum install -y pv
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y pv
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm pv
    else
        echo "未找到合适的包管理器，无法安装 pv。请手动安装。"
    fi
else
    echo "pipe view binary [checked]"
fi

. ./demo-magic.sh

clear

p "展示Gatekeeper在资源控制方面的能力：对资源的创建和修改行为严格限制与实时监控，阻止不符合政策的资源操作，保障集群资源的规范性和一致性"

pe "cat sync.yaml"

pe "kubectl apply -f sync.yaml"

pe "kubectl create ns no-label"

pe "cat templates/k8srequiredlabels_template.yaml"

pe "kubectl apply -f templates/k8srequiredlabels_template.yaml"

pe "cat constraints/all_ns_must_have_gatekeeper.yaml"

pe "kubectl apply -f constraints/all_ns_must_have_gatekeeper.yaml"

pe "kubectl apply -f bad/bad_ns.yaml"

pe "cat good/good_ns.yaml"

pe "kubectl apply -f good/good_ns.yaml"

pe "cat templates/k8suniquelabel_template.yaml"

pe "kubectl apply -f templates/k8suniquelabel_template.yaml"

pe "kubectl apply -f constraints/all_ns_gatekeeper_label_unique.yaml"

pe "cat good/no_dupe_ns.yaml"

pe "kubectl apply -f good/no_dupe_ns.yaml"

pe "cat bad/no_dupe_ns_2.yaml"

pe "kubectl apply -f bad/no_dupe_ns_2.yaml"

pe "kubectl get k8srequiredlabels ns-must-have-gk -o yaml"


kubectl delete -f constraints
kubectl delete -f templates
kubectl delete -f good
kubectl delete ns no-label
kubectl delete -f sync.yaml
