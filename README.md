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
Habilitamos as linhas 43 a 50 referente ao monitoring e essa função foi possivel visualizar o Cluster overview

![image](https://github.com/user-attachments/assets/8f80697b-5b41-4cff-9fe1-a8da08bef0b4)



Foi necessário inserir as seguintes linhas dentro do values do elasticsearch
```
nodeSets:
- name: masters
  count: 3
  config:
    tracing.apm.enabled: true
    tracing.apm.agent.server_url: "http://apm.eck-elasticsearch.svc:8200"
    xpack.security.transport.ssl.enabled: true
    xpack.security.transport.ssl.verification_mode: certificate
    xpack.monitoring.collection.enabled: true
    # On Elasticsearch versions before 7.9.0, replace the node.roles configuration with the following:
    node.roles: ["master", "remote_cluster_client"]
    xpack.ml.enabled: true
    #node.remote_cluster_client: false
    node.store.allow_mmap: false
  volumeClaimTemplates:
  - metadata:
      name: elasticsearch-data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 35Gi
- name: data
  count: 3
  config:
    tracing.apm.enabled: true
    tracing.apm.agent.server_url: "http://apm.eck-elasticsearch.svc:8200"
    xpack.security.transport.ssl.enabled: true
    xpack.security.transport.ssl.verification_mode: certificate
    xpack.monitoring.collection.enabled: true
    node.roles: ["data", "ingest", "ml", "transform", "remote_cluster_client"]
    #node.remote_cluster_client: false
    node.store.allow_mmap: false
  volumeClaimTemplates:
  - metadata:
      name: elasticsearch-data
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 35Gi
```
Foi necessário habilitar as linhas 310 a 324 do initContainers para melhorar a performance, mas, tivemos problemas de permissão para executar o sysctl
```
sysctl -w vm.max_map_count=262144
```

Foi necessário ajustar o ingress para trabalhar com os seguintes valores, pois tinhamos problemas de protocolo HTTPS
```
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
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
OBS: namespace da police não deixa ser inserido com valores exemplo "-" eck-etasticsearch precisa inserir com o nome sem nenhum caracter especial 
Ex:
![image](https://github.com/user-attachments/assets/dfcfc365-6efc-434c-aabb-b913c678bbfb)

Inserido nas linhas 46 a 51 os valores para APM
```
  config:
    elastic:
      apm:
        active: true
        serverUrl: "http://apm.eck-elasticsearch.svc:8200"
        secretToken: apm-token
```

Foi necesário desativar o campo xpack.fleet.agents.elasticsearch.hosts para que pudecemos editar e inserir os valores abaixo devido a alguns erros de cloud provider e ssl que estavam sendo apresentados em log no agent do kuberntes na linha 53
```
#xpack.fleet.agents.elasticsearch.hosts: ["https://elasticsearch-es-internal-http.eck-elasticsearch.svc:9200"]
```

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

Foi necessário insrir as linha 78 a 88 para habilitar a integração do APM dentro do fleet-server

```
      - package:
          name: apm
        name: apm-1
        inputs:
        - type: apm
          enabled: true
          vars:
          - name: host
            value: 0.0.0.0:8200
          - name: auth.secret_token
            value: apm-token
```

Foi necessário inserir a seguinte anotation para que o ingress funcionasse 

```
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
```


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

Foi necessário inserir as seguintes linhas 71 a 76 para que a porta pudesse ser aberta dentro do container 
```
containers:
  - name: agent  
    ports:
      - name: apm
        containerPort: 8200
        protocol: TCP
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
Download do manifesto via portal kibana tivemos problemas na integração, a solução foi utilizar o seguinte arquivo disposnibilizado no link abaixo e tivemos exito na integração!

```
https://raw.githubusercontent.com/elastic/elastic-agent/8.4/deploy/kubernetes/elastic-agent-managed-kubernetes.yaml
```


### Deletar CRDs

```
kubectl delete -f https://download.elastic.co/downloads/eck/2.14.0/crds.yaml
```
