#!bin/bash

CSJ_ROOT="/home/kaldi-master/egs/csj/online_demo/online-data/models/tri4"
DIR="/home/ASR-online-demo/ASR-demo/demo/static/upload/kaldi"

KALDI_ROOT="/home/kaldi-master"
export PATH=$KALDI_ROOT/tools/openfst/bin:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh

ac_model=$CSJ_ROOT/model
symboltable=$CSJ_ROOT/words.txt
trans_matrix=$CSJ_ROOT/matrix
FST=$CSJ_ROOT/HCLG.fst

r_wav=${DIR}/input.scp
w_trans=${DIR}/trans
w_ali=${DIR}/ali.txt

symtable_nopos=${DIR}/words-nopos.txt
int2sym=${DIR}/int2sym.pl
word_ids=${DIR}/word_ids
result=${DIR}/result

online-wav-gmm-decode-faster --verbose=1 --rt-min=0.8 --rt-max=0.85 \
    --max-active=4000 --beam=12.0 --acoustic-scale=0.0769 \
    scp:$r_wav $ac_model $FST \
    $symboltable '1:2:3:4:5' ark,t:$w_trans \
    ark,t:$w_ali $trans_matrix || exit 1 # 2> $DIR/err.log

cat $w_trans | sed 's/.*-[0-9]* //g' | tr -d "\n" > $word_ids
perl $int2sym $symtable_nopos $word_ids | tr -d " " > $result
