# https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx

## Usage

[Helm](https://helm.sh) must be installed and initialized to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
$ helm repo add codecentric https://codecentric.github.io/helm-charts
```

## Installing the Chart

### To install the chart

```bash
TRAINEE_ACCOUNT=trainee101 && \
kubectx gke_${TRAINEE_ACCOUNT}-sid_asia-southeast2_${TRAINEE_ACCOUNT}-autopilot-cluster && \
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
TRAINEE_ACCOUNT=trainee101 && \
kubectx gke_${TRAINEE_ACCOUNT}-sid_asia-southeast2_${TRAINEE_ACCOUNT}-autopilot-cluster && \
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
