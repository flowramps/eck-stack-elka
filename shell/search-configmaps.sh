#!/bin/bash

# String que estamos procurando
SEARCH_STRING="elasticsearch-es-http.eck-elasticsearch.svc"

# Função para procurar a string em todos os ConfigMaps
search_in_configmaps() {
  echo "Procurando por '$SEARCH_STRING' em todos os ConfigMaps..."

  # Obter todos os namespaces
  namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

  # Percorrer cada namespace
  for namespace in $namespaces; do
    echo "Verificando ConfigMaps no namespace: $namespace"
    
    # Obter todos os ConfigMaps no namespace atual
    configmaps=$(kubectl get configmaps -n $namespace -o jsonpath='{.items[*].metadata.name}')
    
    # Percorrer cada ConfigMap
    for configmap in $configmaps; do
      echo "Verificando ConfigMap: $configmap no namespace: $namespace"
      
      # Verificar se a string aparece no conteúdo do ConfigMap
      configmap_content=$(kubectl get configmap $configmap -n $namespace -o yaml)
      if echo "$configmap_content" | grep -q "$SEARCH_STRING"; then
        echo "Encontrado em $configmap no namespace $namespace"
      fi
    done
  done
}

# Executa a função
search_in_configmaps
