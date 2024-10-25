# eck-operator

Repositório do values 
```
https://artifacthub.io/packages/helm/elastic/eck-operator
```
Instalação
```
helm upgrade eck-operator elastic/eck-operator --version 2.14.0 -f values-eck-operator.yaml -n 
```
# eck-elasticsearch

Repositório do values 
```
https://artifacthub.io/packages/helm/elastic/eck-elasticsearch
```

Instalação
```
helm install eck-elasticsearch elastic/eck-elasticsearch --version 0.12.1 -f values-eck-elasticsearch.yaml -n eck-elasticsearch
```
Recuperar secret
```
kubectl get secret elasticsearch-es-elastic-user -o go-template='{{.data.elastic | base64decode}}'
```

# eck-kibana 

Repositório do values 
```
https://artifacthub.io/packages/helm/elastic/eck-kibana
```
Instalação
```
helm install eck-kibana elastic/eck-kibana --version 0.12.1 -f values-eck-kibana.yaml -n eck-elasticsearch
```
OBS: namespace da police não deixa ser inserido com valores exemplo "-" eck-etasticsearch

Adicionar dentro do config via web no kibana os seguintes valores dentro do campo app/fleet/settings/outputs/fleet-default-output

```
ssl.verification_mode: none
compression_level: 9
processors:
  - add_cloud_metadata:
      providers: ["aws"]
```

Foi necessário criar o serviço de APM na mão pelo arquivo service-apm.yaml


# eck-fleet-server
Repositório do values 
```
https://artifacthub.io/packages/helm/elastic/eck-fleet-server
```

Instalação
```
helm install eck-fleet-server elastic/eck-fleet-server --version 0.12.1 -f values-eck-fleet-server.yaml -n eck-elasticsearch
```

Caso seja necessário validar a porta se está aberta dentro do pod "8200" será necessário acessar o pod e instalar os seguintes recursos para visualização!
```
apt install net-tools
netstat -tuln
```

# Install elastic-agent 
Download do manifesto via portal kibana tivemos problemas na integração, a solução foi utilizar o seguinte arquivo disposnibilizado no link 

```
https://raw.githubusercontent.com/elastic/elastic-agent/8.4/deploy/kubernetes/elastic-agent-managed-kubernetes.yaml
```


# Deletar CRDs

```
kubectl delete -f https://download.elastic.co/downloads/eck/2.14.0/crds.yaml
```