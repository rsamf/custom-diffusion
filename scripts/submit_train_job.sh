#!/bin/bash

## PROJECT_ID and BUCKET_NAME should be set in secrets
DATE=$(date +%Y%m%d_%H%M%S)
MODEL_DIR="output/custom-diffusion-cat-$DATE"
IMAGE_URI=gcr.io/$PROJECT_ID/custom-diffusion:latest
JOB_NAME=cat_job_$DATE

gcloud ai-platform jobs submit training $JOB_NAME \
  --region us-west1 \
  --master-image-uri $IMAGE_URI \
  -- \
  --logdir "gs://$BUCKET_NAME/$MODEL_DIR" \
  --gpus 0,1 \
  --caption '<new1> cat' \
  --modifier_token '<new1>' \
  --name 'cat-sdv4' \
  --base 'input/configs/custom-diffusion/finetune_addtoken.yaml' \
  --datapath 'input/data/cat' \
  --reg_datapath 'input/real_reg/samples_cat/images.txt' \
  --reg_caption 'input/real_reg/samples_cat/caption.txt' \
  --resume-from-checkpoint-custom 'input/sd-v1-4.ckpt'
