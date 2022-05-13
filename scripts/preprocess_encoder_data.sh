###################### What you need to change
## Final output databin, change this to your dir
DATABIN=data-bin 
## DIR of gz dataset: Change this!
DIR=(/brtx/604-nvme1/haoranxu/BETTER_Phase3/oscar/raw/ar/ \
/brtx/604-nvme1/haoranxu/BETTER_Phase3/oscar/raw/fa/ \
/brtx/604-nvme1/haoranxu/BETTER_Phase3/oscar/raw/zh/ \
/brtx/604-nvme1/haoranxu/BETTER_Phase3/oscar/raw/ko/ \
/brtx/604-nvme1/haoranxu/BETTER_Phase3/oscar/raw/en/ \
/brtx/604-nvme1/haoranxu/BETTER_Phase3/oscar/raw/ru/)
#########################

languages=( ar fa zh ko en ru )
last_number=( 85 78 901 52 3155 1057 )

MAX=300
BATCH=5 #preporcess data with 5 files per language as a batch

mkdir -p ${DATABIN}
mkdir -p workspace
for lang in ${languages[@]}; do
    mkdir -p workspace/${lang}
done

## Convert valid jsonl first becasue it will be iteratively used in preprocessing
for (( i=0;i<${#languages[@]};i++)) do
    lang=${languages[i]}
    num=${last_number[i]}
    gunzip <${DIR[i]}/${lang}_meta_part_${num}.jsonl.gz>  workspace/${lang}/valid.jsonl
    python scripts/convert_jsonl2txt.py --input workspace/${lang}/valid.jsonl --output workspace/${lang}/valid.txt --lang ${lang}
done
cat workspace/*/valid.txt | shuf -n 250000 >  workspace/valid.raw.txt

for start_index in $(seq 1 ${BATCH} ${MAX}); do
    ## Convert jsonl to txt based on batch files, 5 files in a batch
    for acc in $(seq 0 `expr ${BATCH} - 1`); do
        index=`expr ${start_index} + ${acc}`
        for (( i=0;i<${#languages[@]};i++)) do
            lang=${languages[i]}
            dir=${DIR[i]}
            filename=${dir}/${lang}_meta_part_${index}.jsonl.gz
            if [ -f  $filename ] && [ ${last_number[i]} != ${index} ] ; then
                echo "Unzipping ${filename}" 
                gunzip <$filename> workspace/${lang}/${index}.jsonl
                python scripts/convert_jsonl2txt.py \
                    --input workspace/${lang}/${index}.jsonl \
                    --output workspace/${lang}/train.${index}.txt \
                    --lang $lang
            fi
        done
    done
    cat workspace/*/train.* > workspace/train.raw.txt

    ## Train tokenizer if we haven't done
    tokenizer=${DATABIN}/spm_64k.model
    if [ ! -f  $tokenizer ]; then
        python ./scripts/spm_train.py \
        --input=workspace/train.raw.txt \
        --model_prefix=${DATABIN}/spm_64k \
        --vocab_size=64000 \
        --character_coverage=0.999999995 \
        --input_sentence_size=10000000 \
        --shuffle_input_sentence=true

        cut -f 1 ${DATABIN}/spm_64k.vocab | tail -n +4 | sed "s/$/ 100/g" > ${DATABIN}/dict.txt
    fi

    ## Tokenizing
    if [ ! -f "workspace/valid.tok.txt" ]; then
        python ./scripts/spm_encode.py \
        --model ${tokenizer} \
        --input workspace/valid.raw.txt \
        --outputs workspace/valid.tok.txt
    fi

    python ./scripts/spm_encode.py \
    --model ${tokenizer} \
    --input workspace/train.raw.txt \
    --outputs workspace/train.tok.txt


    ## Fairseq Preprocess
    fairseq-preprocess \
    --only-source \
    --srcdict ${DATABIN}/dict.txt \
    --trainpref workspace/train.tok.txt \
    --validpref workspace/valid.tok.txt \
    --destdir ${DATABIN}/databin-${start_index} \
    --workers 60

    ## Remove unnecessary files
    rm workspace/train.*
    rm workspace/*/*
done

rm -rf workspace
