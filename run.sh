#!/usr/bin/env ash

set -e

function log() {
  echo "[$(date)] ${1}"
}

OLD_IP="$(kubectl -n "${NAMESPACE}" get configmap "${CONFIG_MAP}" -o jsonpath='{.data.ip}')"
log "old ip    : ${OLD_IP}"

IP="$(curl -sf https://api.ipify.org)"
log "current ip: ${IP}"

if [[ "${IP}" == "${OLD_IP}" ]]; then
  log "ips are identical, exiting"
  exit 0
fi

POPULATED_QUERY="$(printf '{
  "Changes": [{
    "Action":"UPSERT",
    "ResourceRecordSet":{
      "Name":"%s",
      "Type":"A",
      "TTL":60,
      "ResourceRecords":[{
        "Value":"%s"
      }]
    }
  }]
}' "${DNS_NAME}" "${IP}")"

log "updating ip with query: ${POPULATED_QUERY}"

aws route53 change-resource-record-sets \
  --hosted-zone-id "${HOSTED_ZONE_ID}" \
  --change-batch "${POPULATED_QUERY}"

log "writing ip to config map"
export IP
kubectl -n "${NAMESPACE}" get configmap "${CONFIG_MAP}" -o json | jq '.data.ip = env.IP' | kubectl apply -f -

log "done"
