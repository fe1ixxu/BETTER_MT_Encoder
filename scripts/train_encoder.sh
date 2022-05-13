
### These two are what you need to change
# Note that it is the directory including all databins, which is $DATABIN in the preprocess bash file
#-data-bin
#   -databin-1
#   -databin-5
#   -databin-....
DATA_PATH=./data-bin 
# Where to store
STORE_PATH=./models/6LM_large/
########



MAX_UPDATE=1000000 
WARMUP=35000
INTERVAL=5000 

# effective batch size (8 GPUs) = 8*32*8 = 2048
SEQ_LEN=512
# BS=8
FREQ=2
LR=4e-4

ARCH=roberta_base
DATABINS=$(python ./scripts/get_data_bin.py --input $DATA_PATH)
echo $DATABINS
# mkdir -p /srv/local2/shijie/checkpoints/$CODENAME

CUDA_LAUNCH_BLOCKING=1 fairseq-train $DATABINS \
--cpu \
--save-dir ${STORE_PATH} \
--train-subset train \
--fp16 \
--fp16-init-scale 16 \
--memory-efficient-fp16 \
--num-workers 4 \
--task masked_lm \
--criterion masked_lm \
--arch $ARCH \
--sample-break-mode complete \
--max-positions $SEQ_LEN \
--tokens-per-sample $SEQ_LEN \
--optimizer adam \
--adam-betas "(0.9, 0.999)" \
--adam-eps 1e-6 \
--clip-norm 1.0 \
--lr-scheduler polynomial_decay \
--lr $LR \
--warmup-updates $WARMUP \
--dropout 0.1 \
--attention-dropout 0.1 \
--weight-decay 0.01 \
--max-tokens 8192 \
--update-freq $FREQ \
--max-update $MAX_UPDATE \
--total-num-update $MAX_UPDATE \
--required-batch-size-multiple 8 \
--empty-cache-freq 100 \
--skip-invalid-size-inputs-valid-test \
--log-format json \
--log-interval 5 \
--fast-stat-sync \
--seed 1 \
--validate-interval $INTERVAL \
--save-interval-updates $INTERVAL \
--no-epoch-checkpoints \
--keep-interval-updates 5 \
--tensorboard-logdir $STORE_PATH
