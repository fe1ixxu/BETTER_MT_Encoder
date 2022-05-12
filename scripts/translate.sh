INPUT=$1
OUTPUT=$2
MODEL_PATH=$3
lang=$4

mkdir -p tmp_workspace
## Tokenize:
python ./scripts/spm_encode.py \
--model ./vocabs/${lang}/spm_32k.model \
--input $INPUT \
--outputs tmp_workspace/input.txt

## Translate:
cat tmp_workspace/input.txt | \
fairseq-interactive ./vocabs/${lang}/ \
    --path $MODEL_PATH/checkpoint_best.pt \
    --buffer-size 1024 --batch-size 100 \
    --beam 5 --lenpen 1.0 --remove-bpe=sentencepiece | \
grep -P "^H" | cut -f 3- > $OUTPUT

rm -rf tmp_workspace

