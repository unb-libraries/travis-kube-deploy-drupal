#!/usr/bin/env bash
set -e

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

POD_NAME=$(kubectl get pods --namespace=$BRANCH --sort-by=.status.startTime -l tier=$KUBE_DEPLOYMENT_NAME | grep Running | awk '{ print $1 }' | head -n 1)
echo "Pod logs:"
kubectl logs $POD_NAME --namespace=$BRANCH
