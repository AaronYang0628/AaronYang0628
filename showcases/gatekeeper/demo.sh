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
fi

. ../../assets/software/command-magic/demo-magic.sh

clear

p "当前脚本将展示Gatekeeper在 *资源控制* 方面的能力：如 对资源的创建和修改行为严格限制与实时监控，阻止不符合政策的资源操作，保障集群资源的规范性和一致性等"

p "根据官网 https://open-policy-agent.github.io/gatekeeper/website/docs/sync 描述，部分约束可能需要整个集群的信息，所以需要编写一个同步的配置（2种方式），将数据同步到OPA客户端"

pe "cat sync.yaml"

pe "kubectl apply -f sync.yaml"

pe "kubectl create ns no-label"

pe "cat templates/k8srequiredlabels_template.yaml"

p "spec.targets.target.repo中的代码使用的是 Rego 语言。Rego 是 Open Policy Agent（OPA）所使用的一种声明式策略语言，在 Kubernetes 的 Gatekeeper 中，Rego 被用于编写策略规则"

p "这段代码定义了一个名为 violation 的规则(方法)，用于检查 Kubernetes Pod 是否缺少指定的标签。如果 Pod 缺少任何一个必需的标签，该规则就会触发违规，并生成相应的错误消息"

pe "kubectl apply -f templates/k8srequiredlabels_template.yaml"

pe "cat constraints/all_ns_must_have_gatekeeper.yaml"

pe "kubectl apply -f constraints/all_ns_must_have_gatekeeper.yaml"

pe "cat bad/bad_ns.yaml"

pe "kubectl apply -f bad/bad_ns.yaml"

pe "cat good/good_ns.yaml"

pe "kubectl apply -f good/good_ns.yaml"

pe "cat templates/k8suniquelabel_template.yaml"

pe "kubectl apply -f templates/k8suniquelabel_template.yaml"

pe "cat constraints/all_ns_gatekeeper_label_unique.yaml"

pe "kubectl apply -f constraints/all_ns_gatekeeper_label_unique.yaml"

pe "cat good/no_dupe_ns.yaml"

pe "kubectl apply -f good/no_dupe_ns.yaml"

pe "cat bad/no_dupe_ns_2.yaml"

pe "kubectl apply -f bad/no_dupe_ns_2.yaml"

pe "kubectl get k8srequiredlabels ns-must-have-gk -o yaml"

wait

kubectl delete -f constraints
kubectl delete -f templates
kubectl delete -f good
kubectl delete ns no-label
kubectl delete -f sync.yaml
