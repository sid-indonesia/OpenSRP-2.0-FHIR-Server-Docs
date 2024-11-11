# OpenSRP-2.0-FHIR-Server-Docs

This repo consists of documentations and config samples for deploying OpenSRP 2.0 FHIR Server, FHIR Gateway, Keycloak, and FHIR Web in a Kubernetes (k8s) cluster.

# Helpful Tools

## For deploying in Google Cloud Platform
- [`gcloud`](https://cloud.google.com/sdk/docs/install)
- [`kubectl`](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_kubectl)
- [`kubectx` + `kubens`: Power tools for kubectl](https://github.com/ahmetb/kubectx)

## For deploying in local machine
- [`Docker`](https://docs.docker.com/engine/install/)
- [`kubectl`](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#install_kubectl)
- [`kubectx` + `kubens`: Power tools for kubectl](https://github.com/ahmetb/kubectx)
- [Minikube](https://minikube.sigs.k8s.io/docs/start)

## Optional
- Preferred code editor: [Cursor](https://www.cursor.com/)
- Preferred DB administration tool: [DBeaver](https://dbeaver.io/download/)
- Preferred password generator: [Password Generator](https://passwordsgenerator.net/)
- Preferred version control: [GitHub](https://github.com/)

# Extra Notes

- Follow the steps within [./projects/OpenSRP-2/namespaces/team-based-care-dev/README.md](./projects/OpenSRP-2/namespaces/team-based-care-dev/README.md#steps)
- If using DBMS cloud service such as [Google Cloud SQL](https://cloud.google.com/sql/), create database via the cloud console or SQL client, the database name needs to be the same name as the one being referenced in the server applications configurations files.
- Create DB user(s) for the database, and the least privileges permissions for each user(s). See [sample SQL script for modifying permissions](./permissions.sql).
- In older versions of HAPI FHIR JPA Server (< [6.6.0](https://hapifhir.io/hapi-fhir/docs/introduction/changelog.html#changes-24)), change data type of `public.hfj_res_ver.res_text_vc` from `varchar(4000)` to `text` in HAPI FHIR database. The [GitHub Issue](https://github.com/hapifhir/hapi-fhir/pull/4763).
- Restart FHIR Gateway after all other components ready to serve to avoid issue related to `JWT verification failed with error: The Token's Signature resulted invalid when verified using the Algorithm: SHA256withRSA`

# Useful Commands

Levi preferred to call them "Magic Spells", along with his some years of experience in technological wizardry.

## Create a namespace

```bash
NAMESPACE_NAME=team-based-care-dev && \
kubectl create namespace $NAMESPACE_NAME
```

## Apply all manifests in some namespaces

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
PROJECT_NAME=OpenSRP-2 && \
NAMESPACE_NAME=** && \
EXTRA_DIR_PATH=*/*/* && \

for file in projects/$PROJECT_NAME/namespaces/$NAMESPACE_NAME/KubernetesManifests/$EXTRA_DIR_PATH; do
  kubectl apply -f "$file"
done
```

## Refresh all manifests in some namespaces (or projects)

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
PROJECT_NAME=OpenSRP-2 && \
NAMESPACE_NAME=team-based-care* && \
EXTRA_DIR_PATH=*/*/* && \
DIR_PATH=projects/${PROJECT_NAME}/namespaces/${NAMESPACE_NAME}/KubernetesManifests/${EXTRA_DIR_PATH} && \

for file in $DIR_PATH; do
  MANIFEST_FILE_NAME=$(echo "$file" | awk -F'/' '{print $(NF)}') && \
  # extract MANIFEST_NAME from MANIFEST_FILE_NAME without suffix .yaml or .yml
  MANIFEST_NAME=$(echo "$MANIFEST_FILE_NAME" | sed 's/\.yaml$//' | sed 's/\.yml$//') && \
  KUBE_RESOURCE_TYPE=$(echo "$file" | awk -F'/' '{print $(NF-1)}') && \
  API_PATH=$(echo "$file" | awk -F'/' '{print $(NF-2)}') && \
  FILE_NAMESPACE_NAME=$(echo "$file" | awk -F'/' '{print $(NF-4)}') && \
  MANIFEST_PATH=projects/${PROJECT_NAME}/namespaces/${FILE_NAMESPACE_NAME}/KubernetesManifests/${API_PATH}/${KUBE_RESOURCE_TYPE}/${MANIFEST_FILE_NAME} && \
  kubectl get -n "$FILE_NAMESPACE_NAME" ${KUBE_RESOURCE_TYPE} ${MANIFEST_NAME} -o yaml > ${MANIFEST_PATH}
done
```

## Apply all manifests in a namespace

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
PROJECT_NAME=OpenSRP-2 && \
NAMESPACE_NAME=superset && \
EXTRA_DIR_PATH= && \
\
kubectl apply -n "$NAMESPACE_NAME" -f projects/$PROJECT_NAME/namespaces/$NAMESPACE_NAME/KubernetesManifests/$EXTRA_DIR_PATH -R
```

## Refresh a k8s manifest `yaml`

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
PROJECT_NAME=OpenSRP-2 && \
NAMESPACE_NAME=team-based-care-dev && \
MANIFEST_NAME=fhir-gateway-hapi-page-url-allowed-queries && \
KUBE_RESOURCE_TYPE=ConfigMap && \
API_VERSION=$(kubectl get -n "$NAMESPACE_NAME" ${KUBE_RESOURCE_TYPE} ${MANIFEST_NAME} -o jsonpath={.apiVersion}) && \
API_PATH=${API_VERSION%%/*} && \
DIR_PATH=projects/${PROJECT_NAME}/namespaces/${NAMESPACE_NAME}/KubernetesManifests/${API_PATH}/${KUBE_RESOURCE_TYPE} && \
mkdir -p ${DIR_PATH} && \
\
kubectl get -n "$NAMESPACE_NAME" ${KUBE_RESOURCE_TYPE} ${MANIFEST_NAME} -o yaml > ${DIR_PATH}/${MANIFEST_NAME}.yaml
```

## Apply after refresh & modify

```bash
kubectl apply -n "$NAMESPACE_NAME" -f ${DIR_PATH}/${MANIFEST_NAME}.yaml
```

## Apply new manifests in a folder all at once

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
PROJECT_NAME=OpenSRP-2 && \
NAMESPACE_NAME=federated-fhir-ecosystem && \
KUBE_RESOURCE_TYPE=ScaledObject && \
API_PATH=keda.sh && \
DIR_PATH=projects/${PROJECT_NAME}/namespaces/${NAMESPACE_NAME}/KubernetesManifests/${API_PATH}/${KUBE_RESOURCE_TYPE} && \
\
kubectl apply -n "$NAMESPACE_NAME" -f ${DIR_PATH} -R
```

## Get many manifests and put them into `manifests.yaml` + secret manifests and put them into `secrets.yaml`

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
PROJECT_NAME=OpenSRP-2 && \
NAMESPACE_NAME=federated-fhir-ecosystem && \
DIR_PATH=projects/${PROJECT_NAME}/namespaces/${NAMESPACE_NAME}/KubernetesManifests && \
mkdir -p ${DIR_PATH} && \
kubectl get deployment,sts,cm,hpa,vpa,service,ingress,frontendconfigs,mcrt,all -n "${NAMESPACE_NAME}" -o yaml > ${DIR_PATH}/manifests.yaml \
&& \
kubectl get secrets -n "${NAMESPACE_NAME}" -o yaml > ${DIR_PATH}/secrets.yaml
```

## Get many manifests and put them into one `yaml`

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
kubectl get deployment,sts,cm,hpa,vpa,service,ingress -o yaml > some-manifests.yaml
```

## Get all manifests (excluding `Secret`, `ConfigMap`, `Ingress`, `ManagedCertificate`, etc...) and put them into one `yaml`

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
kubectl get all -o yaml > all-manifests.yaml
```

## Get secrets and put them into `secrets.yaml`

```bash
kubectx gke_trainee01-sid_asia-southeast2_trainee01-autopilot-cluster && \
# kubectx minikube && \
kubectl get secrets -o yaml > secrets.yaml
```

# Kubernetes Best Practices

- [Kubernetes best practices: Specifying Namespaces in YAML | Google Cloud Blog](https://cloud.google.com/blog/products/containers-kubernetes/kubernetes-best-practices-organizing-with-namespaces)

## Kubernetes Secret

- [Using Secrets to store sensitive data | Config Connector Documentation | Google Cloud](https://cloud.google.com/config-connector/docs/how-to/secrets)
- [Decode a secret value](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/#decoding-secret)
- [Good practices for Kubernetes Secrets | Kubernetes](https://kubernetes.io/docs/concepts/security/secrets-good-practices/)

## [Mastering the KUBECONFIG file](https://medium.com/@ahmetb/mastering-kubeconfig-4e447aa32c75)

**Merging kubeconfig files**
Since kubeconfig files are structured YAML files, you can’t just append them to get one big kubeconfig file, but kubectl can help you merge these files:

```bash
KUBECONFIG=file1:file2:file3 kubectl config view \
 --merge --flatten > out.txt
```

or

```bash
KUBECONFIG=~/.kube/config:~/.kube.minikube/config kubectl config view \
 --merge --flatten > out.txt
```
