#!/usr/bin/env bash
set -e

DEPLOYMENT_FINISHED_MARKER='99_report_as_complete'
ADDITIONAL_SLEEP_SECONDS='15'

# Update image on Kubernetes. Trigger from Jenkins job with two arguments:
echo "BRANCH $BRANCH"
echo "IMAGE_TAG $IMAGE_TAG"

# Determine time to pause before dumping logs to Jenkins build output.
KUBE_DEPLOYMENT_NAME=$(echo $SERVICE_NAME | sed 's/\./-/g')
SLEEP_SECONDS=$(kubectl get deployment $KUBE_DEPLOYMENT_NAME -o json --namespace=dev | grep minReadySeconds | awk {'print $2'} | sed 's|,||g')

# Update image hash to tag.
echo "Updating image for $SERVICE_NAME - $BRANCH to $IMAGE_TAG in Kubernetes..."
kubectl set image --record deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_NAME}=$AMAZON_ECR_URI/$SERVICE_NAME:$IMAGE_TAG --namespace=${BRANCH}

# Sleep, then dump logs.
echo "Sleeping for ${SLEEP_SECONDS}s to allow pod to come up..."
sleep $SLEEP_SECONDS

POD_NAME=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l tier=$KUBE_DEPLOYMENT_NAME --no-headers | tac | awk '{ print $1 }' | head -n 1)
POD_DEPLOYED='FALSE'

# Logs.
POD_LOGS=$(kubectl logs $POD_NAME --namespace=$BRANCH)

if [[ $POD_LOGS == *"$DEPLOYMENT_FINISHED_MARKER"* ]]; then
  POD_DEPLOYED='TRUE'
fi

while [[ "$POD_DEPLOYED" == "FALSE" ]]; do
  echo "Checking to see if deployment complete.."
  POD_LOGS=$(kubectl logs $POD_NAME --namespace=$BRANCH)
  if [[ $POD_LOGS == *"$DEPLOYMENT_FINISHED_MARKER"* ]]; then
    POD_DEPLOYED='TRUE'
    echo "Yes!"
  fi
  echo "Sleeping $ADDITIONAL_SLEEP_SECONDS more seconds to allow pod to complete deployment..."
  sleep $ADDITIONAL_SLEEP_SECONDS
done

echo "Pod logs:"
echo "$POD_LOGS"

# If error strings found in startup, exit.
LOWER_POD_LOGS=${POD_LOGS,,}
if [[ $LOWER_POD_LOGS == *"error"* ]]; then
  echo "Error found in container startup."
  exit 1
fi
