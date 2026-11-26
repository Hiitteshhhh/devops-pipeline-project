#!/bin/bash

CLUSTER="devops-flask-cluster"
SERVICE="flask-api-service"
REGION="ap-southeast-2"

start() {
  echo "Starting Flask API on ECS..."
  aws ecs update-service \
    --cluster $CLUSTER \
    --service $SERVICE \
    --desired-count 1 \
    --region $REGION > /dev/null

  echo "Waiting for service to start (60 seconds)..."
  sleep 60

  TASK_ARN=$(aws ecs list-tasks --cluster $CLUSTER --region $REGION --query 'taskArns[0]' --output text)
  ENI_ID=$(aws ecs describe-tasks --cluster $CLUSTER --region $REGION --tasks $TASK_ARN --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
  PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --region $REGION --query 'NetworkInterfaces[0].Association.PublicIp' --output text)

  echo "✅ App is live at http://$PUBLIC_IP:5000"
}

stop() {
  echo "Stopping Flask API on ECS..."
  aws ecs update-service \
    --cluster $CLUSTER \
    --service $SERVICE \
    --desired-count 0 \
    --region $REGION > /dev/null
  echo "✅ App stopped — no charges running"
}

status() {
  RUNNING=$(aws ecs describe-services \
    --cluster $CLUSTER \
    --services $SERVICE \
    --region $REGION \
    --query 'services[0].runningCount' \
    --output text)
  echo "Running containers: $RUNNING"

  if [ "$RUNNING" -gt 0 ]; then
    TASK_ARN=$(aws ecs list-tasks --cluster $CLUSTER --region $REGION --query 'taskArns[0]' --output text)
    ENI_ID=$(aws ecs describe-tasks --cluster $CLUSTER --region $REGION --tasks $TASK_ARN --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)
    PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --region $REGION --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
    echo "Live at: http://$PUBLIC_IP:5000"
  fi
}

destroy() {
  echo "Destroying all AWS resources..."
  aws ecs update-service --cluster $CLUSTER --service $SERVICE --desired-count 0 --region $REGION > /dev/null
  aws ecs delete-service --cluster $CLUSTER --service $SERVICE --region $REGION > /dev/null
  cd terraform && terraform destroy -auto-approve
  echo "✅ All resources destroyed — zero charges"
}

case "$1" in
  start)   start ;;
  stop)    stop ;;
  status)  status ;;
  destroy) destroy ;;
  *)
    echo "Usage: bash manage.sh [start|stop|status|destroy]"
    echo ""
    echo "  start   — start ECS container and show live URL"
    echo "  stop    — stop ECS container (no charges)"
    echo "  status  — check if app is running and show URL"
    echo "  destroy — delete ALL AWS resources permanently"
    ;;
esac