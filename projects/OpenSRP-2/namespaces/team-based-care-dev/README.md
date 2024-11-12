# Notes for deploying in different context / environment / account

- Replace all hostnames / domain names (e.g. add/change environment name / account name)
- Change values of Secrets (Secret manifests are git-ignored)
- Add DNS A / CNAME records for the new domain names in the domain control panel, the IP address is using the one used as public IP in the Ingress manifests (or reserve a static external IP beforehand)
- Edit the content of [`keycloak-realm-json.yaml`](./KubernetesManifests/v1/ConfigMap/keycloak-realm-json.yaml) as needed (it is used to import the realm configuration at startup)
- Change respective client ID and secrets in each OAuth client deployments (FHIR Web, FHIR Server with Auth, etc)
- Create needed databases (`keycloak_gke`, `hapi_fhir_team_based_care`) and users
- Apply the Kubernetes Manifests (`kubectl apply -f projects/NextGen/namespaces/team-based-care-dev -R`)

# Steps

1. In Google Cloud SQL, create instance of type "PostgreSQL 15" with the name "postgresql-dev" via console with configurations as instructed in the tutorial video.

   1. Choose Cloud SQL Edition "Enterprise".
   2. Choose Edition preset "Sandbox".
   3. Choose Database version "PostgreSQL 15".
   4. Set Instance ID as "postgresql-dev".
   5. Generate a secure password for the default `postgres` DB user by using the [Password Generator](https://passwordsgenerator.net/) (Password Length: 50, uncheck "Include Symbols", Set "Quantity" as `1`, Click on Generate( V2 ) and then copy and paste it in the password field of Cloud SQL instance creation page.
   6. Select Region "asia-southeast2 (Jakarta)".
   7. For testing, select "Single zone" as the Zonal availability. For production workloads, it is recommended to use "Multiple zones (Highly available)".
   8. Change machine configuration to 1 vCPU and 3.75 GB memory for testing/sandbox.
   9. Tick "Private IP", select network "default", then tap on "SET UP CONNECTION" to enable Service Networking API and then allocate IP range `10.0.0.0/24` with the name as `private-services-subnet`.
   10. In Authorized networks, for testing / non-production add a network with CIDR range `0.0.0.0/0` to enable you connect to that instance via its public IP from a DB client such as [DBeaver](https://dbeaver.io/download/).
   11. Tick "Enable private path".
   12. Add database flags `max_connections` with value `300`, and `cloudsql.logical_decoding` with value `on`.
   13. Leave all other settings to their default value.
   14. Click on "CREATE INSTANCE" button.
   15. While waiting for the instance to be created, try to accomplish other steps that can be done in parallel.
   16. After the instance created, create database `hapi_fhir_team_based_care` and `keycloak_gke`, can be done via console.
   17. Connect to the DBMS instance using [DBeaver](https://dbeaver.io/download/) or other SQL client, then create user `admin_team_based_care` and `keycloak_gke` by using the SQL script provided in [here](/permissions.sql), do not forget to connect the correct DB first.

2. Create Kubernetes (k8s) autopilot cluster within Google Kubernetes Engine.
3. In [`Endpoints\postgresql-dev.yaml`](../ancillary-services/KubernetesManifests/v1/Endpoints/postgresql-dev.yaml) Change `CHANGE_THIS_TO_CLOUD_SQL_PRIVATE_IP` to the correct value after creating a Cloud SQL instance.
4. Apply all k8s manifests within the project folder [OpenSRP-2](/projects/OpenSRP-2)

### Alternative Steps

You can either create a k8s cluster via the GCP console (UI) or alternatively via CLI:

```bash
gcloud beta container --project "trainee101-sid" clusters create-auto "trainee101-autopilot-cluster" --region "asia-southeast2" --release-channel "regular" --enable-ip-access --no-enable-google-cloud-access --network "projects/trainee101-sid/global/networks/default" --subnetwork "projects/trainee101-sid/regions/asia-southeast2/subnetworks/default" --cluster-ipv4-cidr "/17" --binauthz-evaluation-mode=DISABLED
```

### Static IP Addresses

Static IP Addresses will be provisioned by SID's System Administrator for `trainee01`-`trainee10` along with their respective DNS A Records. Commands executed to reserve static global external IP addresses were:

```bash
TRAINEE_ACCOUNT=trainee101 && \
gcloud config set account ${TRAINEE_ACCOUNT}@sid-indonesia.org && \
gcloud auth login && \
gcloud config set project ${TRAINEE_ACCOUNT}-sid && \
gcloud compute addresses create fhir-server-auth-dev --project=${TRAINEE_ACCOUNT}-sid --global && \
gcloud compute addresses create fhir-gateway-dev --project=${TRAINEE_ACCOUNT}-sid --global && \
gcloud compute addresses create fhir-web-dev --project=${TRAINEE_ACCOUNT}-sid --global && \
gcloud compute addresses create sso-dev --project=${TRAINEE_ACCOUNT}-sid --global
```