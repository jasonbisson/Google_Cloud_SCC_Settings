# Enable Secure Command Center Settings 

## Purpose
While Security Command Center provides a wonderful set of curated findings, the question eventually comes up about making sure Security Command Center services stay enabled to keep the findings flowing to your favorite SEIM. To address this Mitre technique of impairing defenses, I've created a tactical script that enables the four core services at the organization, folder, and projects levels. The script is intentionally modular and straightforward to pick which services or layers your team wants to enable. Hopefully, the settings API will transition to a terraform resource in the future, but for now, this should help address the gap.

## Prerequisites

### Install gcloud
Download the latest gcloud SDK
https://cloud.google.com/sdk/docs/

### Require security command center permissions 
```
securitycenter.containerthreatdetectionsettings.calculate
securitycenter.containerthreatdetectionsettings.update

securitycenter.eventthreatdetectionsettings.calculate
securitycenter.eventthreatdetectionsettings.update

securitycenter.securityhealthanalyticssettings.calculate
securitycenter.securityhealthanalyticssettings.update

securitycenter.websecurityscannersettings.calculate
securitycenter.websecurityscannersettings.update
```

### Update SCC write settings api quota
[How to update Security Command Center quotas](https://cloud.google.com/security-command-center/quotas)

###  Set required organization name variable 
```
#List organizations the identity has access to. 
$ gcloud organizations list --format=[no-heading] |  awk '{print $1}'

#Set variable the organization name
$ export org_name="example.com"
```
### Update default variable to remove services
By default the script will enable all four scc services, which might not be desired especially for container threat detection. If desired the variable can be updated in the script.
```
export services=("container-threat-detection" "event-threat-detection" "security-health-analytics" "web-security-scanner")
```
### Run script to enable all services at the organization,folder,and projects layers
```
$ ./enable_scc_services.sh 

```
### Analyze the details of the modules of the services at the organization,folder,and projects layers
```
$ ./describe_scc_services_status.sh 

```

### Detective logging alerts
```
protoPayload.authorizationInfo.permission="securitycenter.securityhealthanalyticssettings.update" AND protoPayload.request.securityHealthAnalyticsSettings.serviceEnablementState="DISABLED"

protoPayload.authorizationInfo.permission="securitycenter.websecurityscannersettings.update" AND protoPayload.request.websecurityscannersettings.serviceEnablementState="DISABLED"

protoPayload.authorizationInfo.permission="securitycenter.eventthreatdetectionsettings.update" AND protoPayload.request.eventthreatdetectionsettings.serviceEnablementState="DISABLED"

protoPayload.authorizationInfo.permission="securitycenter.containerthreatdetectionsettings.update" AND protoPayload.request.containerthreatdetectionsettings.serviceEnablementState="DISABLED"
```
### External Documentation
[Security Health Analytics detectors disabled by default](https://cloud.google.com/security-command-center/docs/how-to-use-security-health-analytics#enable_and_disable_detectors)
[How to configure Security Command Center](https://cloud.google.com/security-command-center/docs/how-to-configure-security-command-center)

### To Do
Expand to alert on submodules that are not enables. 
Remove sleep when quota has been updated.