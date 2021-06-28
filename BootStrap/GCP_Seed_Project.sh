######################################################################
## This Script will perform the below actions
## 1) Create a GCP project directly under the GCP Org
## 2) Provision a Terraform service account with required permissions in the seed project
######################VARIABLES
## 1) Dept naming convention. = This will be suffix of seed project dept-seed-project
## 2) Billing account ID to be used.
## 3) Organization ID
##########################USAGE
## sh bootstrap.sh -d 'DEPT NAME' -o orgnaization_id -b 'Billing ID'
######################################################################

#!/bin/bash
cmd_org_list="gcloud organizations list"
cmd_billing_list="gcloud alpha billing accounts list"
usage()
{
    echo "usage: <command> options:<d|o|b|i>"
    echo "syntax: sh bootstrap.sh -d DEPT_NAME -o orgnaization_id -b Billing_ID"
    echo "exmaple sh bootstrap.sh -d SSC -o 1234567891011 -b ######-######-######"
    echo "*** NOTE *** : Using the -i flag with either \"billing\" or \"org\" gives output based on current gcloud settings"
    echo "             : sh bootstrap.sh -i org"
    echo "             : sh bootstrap.sh -i billing"
    echo "Organisation ID avaialble using 'gcloud organizations list'"
    echo "Billing ID Avaialble using 'gcloud alpha billing accounts list'"
}

no_args="true"
while getopts dobi: option
do
    case $option in
            d)
                    dpt=${OPTARG};;
            o)
                    org_id=${OPTARG};;
            b)
                    billing_id=${OPTARG};;
            i)
                    if [ ${OPTARG} == 'org' ]
                    then
                        echo $cmd_org_list;
                        $cmd_org_list;
                        exit;
                    elif [ ${OPTARG} == 'billing' ]
                    then
                        echo $cmd_billing_list;
                        $cmd_billing_list;
                        exit;
                    fi
            (*)
                    usage
                    exit;;
    esac
    no_args="false"
done

[[ "$no_args" == "true" ]] && { usage; exit 1; }

echo $dpt
echo $org_id
echo $billing_id
seed_project_id="${dpt}-seed-project"
echo $seed_project_id
#echo "seed project id: $seed_project_id";
#echo "org id: $org_id";
#echo "billing id: $billing_id";

act=""




seed_gcp () {

tf="tfadmin-${dpt}"


#Step1 Create GCP seed Project
gcloud projects create "${seed_project_id}" --organization=${org_id}  --quiet

#Step 2 : Associate billing id with project
gcloud beta billing projects link "${seed_project_id}" --billing-account "${billing_id}" --quiet

#Step 3 Create Terraform service account
gcloud iam service-accounts create "${tf}" --display-name "Terraform admin account" --project=${seed_project_id} --quiet
act=`gcloud iam service-accounts list --project="${seed_project_id}" --filter=tfadmin --format="value(email)"`

#Step 4 Assign org level and project level role to TF account
gcloud organizations add-iam-policy-binding ${org_id}  --member=serviceAccount:${act} \
    --role=roles/billing.user \
    --role=roles/compute.networkAdmin \
    --role=roles/compute.xpnAdmin \
    --role=roles/iam.organizationRoleAdmin \
    --role=roles/orgpolicy.policyAdmin \
    --role=role/resourcemanager.folderAdmin \
    --role=roles/resourcemanager.organizationAdmin \
    --role=roles/resourcemanager.projectCreator \
    --role=roles/resourcemanager.projectDeleter \
    --role=roles/resourcemanager.projectIamAdmin \
    --role=roles/resourcemanager.projectMover   \
    --role=roles/orgpolicy.PolicyAdmin \
    --role=roles/logging.configWriter  \
    --role=roles/resourcemanager.projectIamAdmin  \
    --role=roles/serviceusage.serviceUsageAdmin  \
    --role=roles/bigquery.dataEditor



}


main () {

seed_gcp
status=$?
if [ $status == 0 ]
then
echo "GCP seed project created project id: ""${seed_project_id} \n"
echo " Terraform Service account to be used for creating GCP landing zone = " "${act} \n"
echo " Please follow instructions to setup Terraform service account keys before launching Terraform scripts."
else
echo " GCP service account creation failed. Please debug and rerun"
fi
}

main
