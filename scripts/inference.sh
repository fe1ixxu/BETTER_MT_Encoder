MODEL_PATH=$1
lg=$2
DATA_DIR=../preprocessed_mt_data/

TGT=en
FSRC=${DATA_DIR}/tok-v2/en-${lg}/test.en
FTGT=${DATA_DIR}/raw-v2/en-${lg}/test.${lg}
FOUT=${MODEL_PATH}/results/test.en-${lg}.${lg}
mkdir -p ${MODEL_PATH}/results

cat $FSRC | \
CUDA_VISIBLE_DEVICES=5 fairseq-interactive ${DATA_DIR}/data-bin-v2/en-${lg}/ \
    --path $MODEL_PATH/checkpoint_best.pt \
    --buffer-size 1024 --batch-size 100 \
    --beam 5 --lenpen 1.0 --remove-bpe=sentencepiece | \
grep -P "^H" | cut -f 3- > $FOUT

cat ${FOUT} | sacrebleu $FTGT -m bleu -b -w 2 > ${FOUT}.bleu
head ${FOUT}.bleu

