## Dependencies
```
conda create -n better-mt python=3.8
conda activate better-mt
pip install -e ./
pip install sentencepiece
pip install tensorboardX
```

## Translate from any English files to the target language:
Note this repo only supports en->ko, en->ru and en->zh:
```
bash scripts/translate.sh $INPUT_FILE $OUTPUT_FILE $MODEL_DIR $language
```
For example, translate English file `tmp.en` to Russian `tmp.ru`, where model directory is `./model`
```
bash scripts/translate.sh tmp.en tmp.ru ./model ru
```