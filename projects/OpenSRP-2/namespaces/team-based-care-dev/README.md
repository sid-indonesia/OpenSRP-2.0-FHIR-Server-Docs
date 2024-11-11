# Notes for deploying in different context / environment / account

- Replace all hostnames / domain names (e.g. add/change environment name / account name)
- Change values of Secrets (Secret manifests are git-ignored)
- Add DNS A / CNAME records for the new domain names in the domain control panel, the IP address is using the one used as public IP in the Ingress manifests (or reserve a static external IP beforehand)
- Edit the content of [`keycloak-realm-json.yaml`](./KubernetesManifests/v1/ConfigMap/keycloak-realm-json.yaml) as needed (it is used to import the realm configuration at startup)
- Change respective client ID and secrets in each OAuth client deployments (FHIR Web, FHIR Server with Auth, etc)
- Create needed databases (`keycloak_gke`, `hapi_fhir_team_based_care`) and users
- Apply the Kubernetes Manifests (`kubectl apply -f projects/NextGen/namespaces/team-based-care-dev -R`)

# Steps

1. Execute these to reserve static global external IP addresses:

   ```bash
   TRAINEE_ACCOUNT=trainee01 && \
   gcloud config set project ${TRAINEE_ACCOUNT}-sid && \
   gcloud compute addresses create fhir-server-auth-dev --project=${TRAINEE_ACCOUNT}-sid --global && \
   gcloud compute addresses create fhir-gateway-dev --project=${TRAINEE_ACCOUNT}-sid --global && \
   gcloud compute addresses create fhir-web-dev --project=${TRAINEE_ACCOUNT}-sid --global && \
   gcloud compute addresses create sso-dev --project=${TRAINEE_ACCOUNT}-sid --global
   ```

2. In [`Endpoints\postgresql-dev.yaml`](../ancillary-services/KubernetesManifests/v1/Endpoints/postgresql-dev.yaml) Change `CHANGE_THIS_TO_CLOUD_SQL_PRIVATE_IP` to the correct value after creating a Cloud SQL instance.
