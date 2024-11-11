# https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx

## Installing the Chart

### To install the chart

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
PROJECT_NAME=OpenSRP-2 && \
NAMESPACE_NAME=team-based-care-dev && \
HELM_VALUES_FILE=keycloak.values.yaml && \
RELEASE_NAME=keycloak && \
REGISTRY_NAME=codecentric && \
REPOSITORY_NAME=keycloakx && \
CHART_VERSION=2.3.0 && \
\
helm install -n "$NAMESPACE_NAME" -f projects/${PROJECT_NAME}/namespaces/${NAMESPACE_NAME}/Helm/$HELM_VALUES_FILE $RELEASE_NAME ${REGISTRY_NAME}/${REPOSITORY_NAME} --version ${CHART_VERSION}
```

#### To upgrade the chart

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
PROJECT_NAME=OpenSRP-2 && \
NAMESPACE_NAME=team-based-care-dev && \
HELM_VALUES_FILE=keycloak.values.yaml && \
RELEASE_NAME=keycloak && \
REGISTRY_NAME=codecentric && \
REPOSITORY_NAME=keycloakx && \
CHART_VERSION=2.3.0 && \
\
helm upgrade -n "$NAMESPACE_NAME" -f projects/${PROJECT_NAME}/namespaces/${NAMESPACE_NAME}/Helm/$HELM_VALUES_FILE $RELEASE_NAME ${REGISTRY_NAME}/${REPOSITORY_NAME} --version ${CHART_VERSION}
```

## To [debug]
