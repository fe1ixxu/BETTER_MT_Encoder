#!/bin/bash
source ~/.bashrc
conda activate better-mt

lg=ru
SAVE_DIR=../models/en-${lg}/v2/
fairseq-train ../preprocessed_mt_data/data-bin-v2/en-${lg} --arch transformer_vaswani_wmt_en_de_big --task translation \
--criterion label_smoothed_cross_entropy --label-smoothing 0.1 --optimizer adam --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
--lr-scheduler inverse_sqrt --lr 0.0005 --warmup-updates 4000 --max-update 50000 --dropout 0.3 --attention-dropout 0.1 \
--weight-decay 0.001 --max-tokens 4096 --update-freq 16 --keep-interval-updates 1 \
--save-interval-updates 500 --no-epoch-checkpoints --patience 30 --share-all-embeddings \
--fp16  --fp16-init-scale 16  --ddp-backend no_c10d \
--save-dir ${SAVE_DIR} --max-source-positions 512 --max-target-positions 512 \
--skip-invalid-size-inputs-valid-test --tensorboard-logdir ${SAVE_DIR}/log/