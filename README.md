## Dependencies
```
conda create -n better-mt python=3.8
conda activate better-mt
pip install -e ./
pip install sentencepiece
pip install tensorboardX
pip install transformers
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
Models are located at brtx box:
```
/brtx/604-nvme1/haoranxu/BETTER_Phase3/models/en-${language}/v2/
```

## Multilingual Encoder
### Preprocessing
Note that you only need to change the `$DATABIN` and `$DIR`
```
bash scripts/preprocess_encoder_data.sh
```

### Train the model
Please set your storage path `$STORE_PATH` and `$DATA_PATH`
```
bash scripts/train_encoder.sh
```
If you meet issues like "device-assert", it is the problem of the dataset. Go `scripts/convert_jsonl2txt.py` to reduce the max length, e.g. from 512 to 256.
### Transfer to Huggingface checkpoint
It is a liitle bit hacky to do this.

Step 1: rename your best/last checkpoint to `model.pt` and copy `dict.txt` to `$STORE_PATH`
```
cp $STORE_PATH/checkpoint_last.pt $STORE_PATH/model.pt
cp `$DATA_PATH/dict.txt $STORE_PATH
```

Step 2: 
Run `convert_roberta_original_pytorch_checkpoint_to_pytorch.py`
```
python scripts/convert_roberta_original_pytorch_checkpoint_to_pytorch.py \
--roberta_checkpoint_path $DATA_PATH \
--pytorch_dump_folder_path $HG_PATH
```
Step 3:
Now your huggingface checkpoint is in `$HG_PATH`. Copy sentencepiece model to `$HG_PATH`:
```
cp $DATA_PATH/spm_64k.model $HG_PATH/sentencepiece.bpe.model
```
Step 4: Rename `model_type` field in `$HG_PATH/config.json` to `xlm-roberta` instead of `roberta`

Now you can use `AutoModel` and `AutoTokenizer` to load our customized model by
```
from transformers import AutoModel, AutoTokenizer
model = AutoModel("$HG_PATH")
tokenizer = AutoTokenizer(""$HG_PATH")
```
