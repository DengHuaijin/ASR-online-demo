#!/bin/bash

THCHS30="/home/kaldi-master/egs/thchs30/online"
NNET="/home/ASR-online-demo/ASR-demo/demo/static/upload/kaldi/nnet/Chinese"

KALDI_ROOT="/home/kaldi-master"
export PATH=$KALDI_ROOT/tools/openfst/bin:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh

acwt=0.1
min_active=200
max_active=7000
feature_transform=
nnet_forward_opts="--no-softmax=true --prior-scale=1.0"

lattice_beam=10.0
beam=18.0
max_mem=50000000
use_gpu="no"
num_threads=1

nnet=$THCHS30/model/final.nnet
model=$THCHS30/model/final.mdl
[ -z "$feature_transform" -a -e $THCHS30/model/final.feature_transform ] && feature_transform=$THCHS30/model/final.feature_transform
class_frame_counts=$THCHS30/model/ali_train_pdf.counts

for f in $NNET/wav.scp $nnet $model $feature_transform $class_frame_counts $THCHS30/model/HCLG.fst; do
	[ ! -f $f ] && echo "$0: missing file $f" && exit 1;
done

thread_string=
[ $num_threads -gt 1 ] && thread_string="-parallel --num-treads=$num_threads"

online_cmvn_opts=
cmvn_opts=
delta_opts=
[ -e $THCHS30/conf/online_cmvn_opts ] && online_cmvn_opts=$(cat $THCHS30/conf/online_cmvn_opts)
[ -e $THCHS30/conf/cmvn_opts ] && cmvn_opts=$(cat $THCHS30/conf/cmvn_opts)
[ -e $THCHS30/conf/delta_opts ] && delta_opts=$(cat $THCHS30/data/delta_opts)

#### fbank features extraction ####
cmvndir=$NNET/data/cmvn
fbank_config=$THCHS30/conf/fbank.conf
logdir=$NNET/log
wavscp=$NNET/wav.scp
vtln_opts=
write_num_frames_opt="--write-num-frames=ark,t:$logdir/utt2num_frames"
write_utt2dur_opt="--write-utt2dur=ark,t:$logdir/utt2dur_opt"
compute-fbank-feats $write_utt2dur_opt --verbose=2 \
	--config=$fbank_config scp,p:$wavscp ark:- | \
	copy-feats $write_num_frames_opt ark:- ark,scp:$NNET/data/raw_fbank.ark,$NNET/data/raw_fbank.scp

compute-cmvn-stats --spk2utt=ark:$THCHS30/data/spk2utt scp:$NNET/data/raw_fbank.scp \
	ark,scp:$cmvndir/cmvn.ark,$cmvndir/cmvn.scp

#### ####

feats="ark:copy-feats scp:$NNET/data/raw_fbank.scp ark:- |"
[ -n "$cmvn_opts" ] && feats="$feats apply-cmvn $cmvn_opts --utt2spk=ark:$THCHS30/data/utt2spk scp:$cmvndir/cmvn.scp ark:- ark:- |"
[ -n "$delta_opts" ] && feats="$feats add-deltas $delta_opts ark:- ark:- |"

symtab=$THCHS30/data/words.txt
nnet-forward $nnet_forward_opts --feature_transform=$feature_transform --class-frame-counts=$class_frame_counts \
	--use_gpu=$use_gpu "$nnet" "$feats" ark:$NNET/model/output.ark

latgen-faster-mapped$thread_string --min-active=$min_active --max-active=$max_active --max-mem=$max_mem --beam=$beam \
	--lattice-beam=$lattice_beam --acoustic-scale=$acwt --allow-partial=true --word-symbol-table=$symtab \
	$model $THCHS30/model/HCLG.fst ark:$NNET/model/output.ark ark:$NNET/lattice

min_lmwt=4
max_lmwt=15
word_ins_penalty=0.5
lattice-scale --inv-acoustic-scale=$max_lmwt ark:$NNET/lattice ark:- | \
	lattice-add-penalty --word-ins-penalty=$word_ins_penalty ark:- ark:- | \
	lattice-best-path --word-symbol-table=$symtab ark:- ark,t:$NNET/word_ids
perl $THCHS30/int2sym.pl -f 2- $symtab $NNET/word_ids | tr -d "kaldiAudio " > $NNET/result
