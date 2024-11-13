# Notes for deploying in different context / environment / account

- Replace all hostnames / domain names (e.g. add/change environment name / account name)
- Change values of Secrets (Secret manifests are git-ignored)
- Add DNS A / CNAME records for the new domain names in the domain control panel, the IP address is using the one used as public IP in the Ingress manifests (or reserve a static external IP beforehand)
- Edit the content of [`keycloak-realm-json.yaml`](./KubernetesManifests/v1/ConfigMap/keycloak-realm-json.yaml) as needed (it is used to import the realm configuration at startup)
- Change respective client ID and secrets in each OAuth client deployments (FHIR Web, FHIR Server with Auth, etc)
- Create needed databases (`keycloak_gke`, `hapi_fhir_team_based_care`) and users
- Apply the Kubernetes Manifests.

# Steps

1. Open [Cloud Shell Editor](https://ide.cloud.google.com), click on `Clone Repository` button and clone [this repository](https://github.com/sid-indonesia/OpenSRP-2.0-FHIR-Server-Docs) https://github.com/sid-indonesia/OpenSRP-2.0-FHIR-Server-Docs, open the cloned repository by clicking on "Open" button on the pop-up dialog after the cloning process is finished.
2. Replace all text value `trainee101` within all files (use [Global Search](https://code.visualstudio.com/docs/editor/codebasics#_search-across-files)) with your assigned trainee account number (e.g. `trainee03`).
3. In Google Cloud SQL, create instance of type "PostgreSQL 15" with the name "postgresql-dev" via console with configurations as instructed in the [tutorial video](https://drive.google.com/file/d/114Ns61fyElFy9EFtmdvZmaRTBXTeFlRH/view?usp=drive_link).

   1. Choose Cloud SQL Edition "Enterprise".
   2. Choose Edition preset "Sandbox".
   3. Choose Database version "PostgreSQL 15".
   4. Set Instance ID as "postgresql-dev".
   5. Generate a secure password for the default `postgres` DB user by using the [Password Generator](https://passwordsgenerator.net/) (Password Length: 50, uncheck "Include Symbols", Set "Quantity" as `1`, Click on `Generate( V2 )` button and then copy and paste it in the password field of Cloud SQL instance creation page.
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
   17. In [`Endpoints\postgresql-dev.yaml`](../ancillary-services/KubernetesManifests/v1/Endpoints/postgresql-dev.yaml) Change `CHANGE_THIS_TO_CLOUD_SQL_PRIVATE_IP` to the correct value (Private IP Address of the newly-created Cloud SQL instance) after creating a Cloud SQL instance.
   18. Connect to the DBMS instance using [DBeaver](https://dbeaver.io/download/) or other SQL client, then create user `admin_team_based_care` and `keycloak_gke` with password set as `CHANGE_THIS` to match with the ones stored in the k8s Secret manifests, use the SQL script provided in [here](/permissions.sql), do not forget to connect the correct DB first.
       - Grant all privileges to the database `hapi_fhir_team_based_care` for user `admin_team_based_care`.
       - Grant all privileges to the database `keycloak_gke` for user `keycloak_gke`.

4. Create Kubernetes (k8s) autopilot cluster within Google Kubernetes Engine. Can use the following commands in Cloud Shell:
   ```bash
   TRAINEE_ACCOUNT=trainee101 && \
   PROJECT_ID=${TRAINEE_ACCOUNT}-sid && \
   gcloud --project=${PROJECT_ID} \
    services enable \
    container.googleapis.com \
    containerregistry.googleapis.com && \
   gcloud beta container \
    --project "${PROJECT_ID}" \
    clusters create-auto "${TRAINEE_ACCOUNT}-autopilot-cluster" \
    --region "asia-southeast2" \
    --release-channel "regular" \
    --enable-ip-access \
    --no-enable-google-cloud-access \
    --network "projects/${PROJECT_ID}/global/networks/default" \
    --subnetwork "projects/${PROJECT_ID}/regions/asia-southeast2/subnetworks/default" \
    --cluster-ipv4-cidr "/17" \
    --binauthz-evaluation-mode=DISABLED
   ```
5. After the Cloud SQL and k8s cluster provisioned and prepared, within [Cloud Shell Editor](https://ide.cloud.google.com), apply all k8s manifests within the project folder [OpenSRP-2](/projects/OpenSRP-2), make sure change directory to [the top folder "OpenSRP-2.0-FHIR-Server-Docs"](/) first, then execute these commands:

   ```bash
   # Create namespacess
   TRAINEE_ACCOUNT=trainee101 && \
   PROJECT_ID=${TRAINEE_ACCOUNT}-sid && \
   kubectx gke_${PROJECT_ID}_asia-southeast2_${TRAINEE_ACCOUNT}-autopilot-cluster && \
   NAMESPACE_NAME=team-based-care-dev && \
   kubectl create namespace $NAMESPACE_NAME && \
   \
   NAMESPACE_NAME=ancillary-services && \
   kubectl create namespace $NAMESPACE_NAME
   \
   \
   \
   # Apply all manifests in some namespaces
   PROJECT_NAME=OpenSRP-2 && \
   NAMESPACE_NAME=** && \
   EXTRA_DIR_PATH=*/*/* && \

   for file in projects/$PROJECT_NAME/namespaces/$NAMESPACE_NAME/KubernetesManifests/$EXTRA_DIR_PATH; do
   kubectl apply -f "$file"
   done
   ```

6. Helm add repo keycloak and then helm install keycloak, see [the markdown file within the Helm directory](/projects/OpenSRP-2/namespaces/team-based-care-dev/Helm/README.md).
7. Wait for all workloads have green check mark which means they are ready to serve. (N.B.: FHIR Gateway workload will depend on Keycloak until Keycloak gets its TLS certificate active)
8. In older versions of HAPI FHIR JPA Server (< [6.6.0](https://hapifhir.io/hapi-fhir/docs/introduction/changelog.html#changes-24)), change data type of `public.hfj_res_ver.res_text_vc` from `varchar(4000)` to `text` in HAPI FHIR database. The [GitHub Issue](https://github.com/hapifhir/hapi-fhir/pull/4763).
   1. Connect to the DBMS instance using [DBeaver](https://dbeaver.io/download/) or other SQL client with user `admin_team_based_care` (password was set to `CHANGE_THIS`), then alter the data type of column `public.hfj_res_ver.res_text_vc` within database `hapi_fhir_team_based_care` from data type `varchar(4000)` to `text`.
9. Restart FHIR Gateway after all other components ready to serve to avoid issue related to `JWT verification failed with error: The Token's Signature resulted invalid when verified using the Algorithm: SHA256withRSA`

### GCP Project Creation Script

GCP Projects will be provisioned by SID's System Administrator for `trainee01`-`trainee10`. The script used was:

```bash
# Need to set environment variables: `SID_GCP_BILLING_ACCOUNT_ID`

# Folder ID for folder "Training Grounds"
FOLDER_ID=271999659456 && \
\
for i in {01..10}; do
  TRAINEE_ACCOUNT=trainee$i && \
  PROJECT_ID=${TRAINEE_ACCOUNT}-sid && \
  gcloud projects create ${PROJECT_ID} \
    --folder=${FOLDER_ID} && \
  gcloud billing projects link ${PROJECT_ID} --billing-account ${SID_GCP_BILLING_ACCOUNT_ID} && \
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${TRAINEE_ACCOUNT}@sid-indonesia.org" \
    --role='roles/owner'
done
```

To cleanup, execute these commands:

```bash
for i in {01..10}; do
  TRAINEE_ACCOUNT=trainee$i && \
  PROJECT_ID=${TRAINEE_ACCOUNT}-sid && \
  gcloud billing projects unlink ${PROJECT_ID} && \
  gcloud projects delete ${PROJECT_ID} --quiet
done
```

### Static External IP Addresses and DNS A Records

Static External IP Addresses will be provisioned by SID's System Administrator for `trainee01`-`trainee10` along with their respective DNS A Records. Commands executed to reserve static global external IP addresses and create DNS records for them were:

```bash
# Need to set environment variables: `SID_SUPER_ADMIN_GOOGLE_ACCOUNT`, `WIX_ACCOUNT_ID`, `WIX_API_KEY_TO_MANAGE_DOMAINS`

# Set your domain name
DOMAIN_NAME="sid-indonesia.org" && \
\
# gcloud config set account ${SID_SUPER_ADMIN_GOOGLE_ACCOUNT} && \
# gcloud auth login && \
\
for i in {01..10}; do
  TRAINEE_ACCOUNT=trainee$i && \
  PROJECT_ID=${TRAINEE_ACCOUNT}-sid && \
  gcloud services enable compute.googleapis.com --project=${PROJECT_ID} && \
  gcloud compute addresses create \
    fhir-server-auth-dev \
    fhir-gateway-dev \
    fhir-web-dev \
    sso-dev \
    --project=${PROJECT_ID} \
    --global

  # Get the list of static IP addresses and their names
  IP_ADDRESSES=$(gcloud compute addresses list --project=${PROJECT_ID} --format="value(NAME, ADDRESS)" | grep -e "-dev")

  # Prepare the JSON structure for the DNS records
  DNS_RECORDS=""

  # Loop through each IP address and format it into the JSON structure
  while IFS= read -r line; do
    NAME=$(echo "$line" | awk '{print $1}' | sed 's/-dev/\.dev/' | sed 's/fhir-server-auth/fhir-server/')
    NAME="${TRAINEE_ACCOUNT}.${NAME}"
    IP=$(echo "$line" | awk '{print $2}')

    # Append to DNS_RECORDS
    DNS_RECORDS+="{
        \"values\": [\"$IP\"],
        \"ttl\": 3600,
        \"hostName\": \"$NAME.$DOMAIN_NAME\",
        \"type\": \"A\"
    },"
  done <<< "$IP_ADDRESSES"

  # Remove the trailing comma from the last record
  DNS_RECORDS=${DNS_RECORDS%,}

  # Create the final JSON payload
  JSON_PAYLOAD="{
    \"domainName\": \"$DOMAIN_NAME\",
    \"additions\": [
        $DNS_RECORDS
    ]
  }"

  # Make the cURL request to the Wix API
  curl -X PATCH "https://www.wixapis.com/domains/v1/dns-zones/${DOMAIN_NAME}" \
  -H "wix-account-id: $WIX_ACCOUNT_ID" \
  -H "Authorization: $WIX_API_KEY_TO_MANAGE_DOMAINS" \
  -d "$JSON_PAYLOAD"
done
```

To cleanup, execute these:

```bash
# Need to set environment variables: `SID_SUPER_ADMIN_GOOGLE_ACCOUNT`, `WIX_ACCOUNT_ID`, `WIX_API_KEY_TO_MANAGE_DOMAINS`

# Set your domain name
DOMAIN_NAME="sid-indonesia.org" && \
\
# gcloud config set account ${SID_SUPER_ADMIN_GOOGLE_ACCOUNT} && \
# gcloud auth login && \
\
for i in {01..10}; do
  TRAINEE_ACCOUNT=trainee$i && \
  PROJECT_ID=${TRAINEE_ACCOUNT}-sid && \

  # Prepare the JSON structure for the DNS records
  DNS_RECORDS=""

  # Loop through each hostNames and format it into the JSON structure
  for hostName in \
    $TRAINEE_ACCOUNT.fhir-gateway.dev.sid-indonesia.org \
    $TRAINEE_ACCOUNT.fhir-server.dev.sid-indonesia.org \
    $TRAINEE_ACCOUNT.fhir-web.dev.sid-indonesia.org \
    $TRAINEE_ACCOUNT.sso.dev.sid-indonesia.org; do

    # Append to DNS_RECORDS
    DNS_RECORDS+="{
        \"values\": [\"0.0.0.0\"],
        \"hostName\": \"$hostName\",
        \"type\": \"A\"
    },"
  done

  # Remove the trailing comma from the last record
  DNS_RECORDS=${DNS_RECORDS%,}

  # Create the final JSON payload
  JSON_PAYLOAD="{
    \"domainName\": \"$DOMAIN_NAME\",
    \"deletions\": [
        $DNS_RECORDS
    ]
  }"

  # Make the cURL request to the Wix API
  curl -X PATCH "https://www.wixapis.com/domains/v1/dns-zones/${DOMAIN_NAME}" \
  -H "wix-account-id: $WIX_ACCOUNT_ID" \
  -H "Authorization: $WIX_API_KEY_TO_MANAGE_DOMAINS" \
  -d "$JSON_PAYLOAD"

  echo "";

  gcloud compute addresses delete \
    fhir-server-auth-dev \
    fhir-gateway-dev \
    fhir-web-dev \
    sso-dev \
    --project=${PROJECT_ID} \
    --global --quiet
done
```
