#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#set -x

export services=("container-threat-detection" "event-threat-detection" "security-health-analytics" "web-security-scanner")

function check_variables () {
    if [  -z "$org_name" ]; then
        printf "ERROR: GCP organization name variable is not set.\n\n"
        printf "This variable is required to retrieve the GCP organization id\n\n"
        printf "example: export org_name="example.com""
        exit
        else 
        export org_id=$(gcloud organizations list --format=[no-heading] | grep ^${org_name} | awk '{print $2}')
    fi

    if [  -z "$org_id" ]; then
        printf "ERROR: GCP organization id variable is not set.\n\n"
        printf "Check if identity has perimission to run: gcloud organizations list\n\n"
        exit
    fi

}

function describe_organization () {
    for service in ${services[*]}; do
        gcloud alpha scc settings services describe --service=$service --organization=$org_id
        sleep 60
    done
}

function describe_folders () {
    for folder in $(gcloud asset search-all-resources --asset-types=cloudresourcemanager.googleapis.com/Folder --scope=organizations/$org_id --format='json(name.basename())' |jq -r '.[].name'); do
        for service in ${services[*]}; do
            gcloud alpha scc settings services describe --service=$service --folder=$folder
            sleep 60
        done
    done
}

function describe_projects () {
    for project in $(gcloud asset search-all-resources --asset-types=cloudresourcemanager.googleapis.com/Project --scope=organizations/$org_id --format='json(name.basename())' |jq -r '.[].name'); do
        for service in ${services[*]}; do
            gcloud alpha scc settings services describe --service=$service --project=$project
            sleep 60
        done
    done
}

check_variables
describe_organization
describe_folders
describe_projects