### eck-operator

Repositório do values 
```
https://artifacthub.io/packages/helm/elastic/eck-operator
```
Instalação
```
helm upgrade eck-operator elastic/eck-operator --version 2.14.0 -f values-eck-operator.yaml -n 
```
### eck-elasticsearch

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

### eck-kibana 

Repositório do values 
```
https://artifacthub.io/packages/helm/elastic/eck-kibana
```
Instalação
```
helm install eck-kibana elastic/eck-kibana --version 0.12.1 -f values-eck-kibana.yaml -n eck-elasticsearch
```
OBS: namespace da police não deixa ser inserido com valores exemplo "-" eck-etasticsearch

Adicionar dentro do config via web no kibana, os seguintes valores no edit do output do Elasticsearch do campo app/fleet/settings/outputs/fleet-default-output

```
ssl.verification_mode: none
compression_level: 9
processors:
  - add_cloud_metadata:
      providers: ["aws"]
```
Ex:

![image](https://github.com/user-attachments/assets/370bf26f-ab44-495d-839b-2048b94c1b32)



Foi necessário implantar o serviço do APM na mão, pelo arquivo service-apm.yaml

Ex:
![image](https://github.com/user-attachments/assets/fae65301-5a17-4f1a-8cd3-9e7466684358)


### eck-fleet-server
Repositório do values 
```
https://artifacthub.io/packages/helm/elastic/eck-fleet-server
```

Instalação
```
helm install eck-fleet-server elastic/eck-fleet-server --version 0.12.1 -f values-eck-fleet-server.yaml -n eck-elasticsearch
```

Caso seja necessário validar a porta se está aberta dentro do pod "8200" será necessário acessar o pod e instalar os seguintes recursos para visualização!
Acessar container 
```
k exec -it fleet-server-agent-5874d7c968-6xfwr /bin/bash
```
Instalar pacote net-tools
```
apt install net-tools
netstat -tuln
```
Ex:
![image](https://github.com/user-attachments/assets/5a760170-0f41-455b-a737-1b9f96cce211)



### Install elastic-agent 
Download do manifesto via portal kibana tivemos problemas na integração, a solução foi utilizar o seguinte arquivo disposnibilizado no link 

```
https://raw.githubusercontent.com/elastic/elastic-agent/8.4/deploy/kubernetes/elastic-agent-managed-kubernetes.yaml
```


### Deletar CRDs

```
kubectl delete -f https://download.elastic.co/downloads/eck/2.14.0/crds.yaml
```
