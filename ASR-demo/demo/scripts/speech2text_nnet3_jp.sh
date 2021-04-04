#!bin/bash

CSJ_ROOT="/home/kaldi-master/egs/csj/online_demo/online-data/models/nnet3"
NNET3="/home/ASR-online-demo/ASR-demo/demo/static/upload/kaldi/nnet3/Japanese"

KALDI_ROOT="/home/kaldi-master"
export PATH=$KALDI_ROOT/tools/openfst/bin:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh

# nnet3
silence_weight=1.0
max_state_duration=40
do_endpointing=false
frames_per_chunk=20
extra_left_context_initial=0
online=true
frame_subsampling_opt="--frame-subsampling-factor=3"
online_config=$CSJ_ROOT/online.conf
min_active=200
max_active=7000
beam=15.0
lattice_beam=6.0
acwt=1.0
post_decode_acwt=10.0
symtable=$CSJ_ROOT/words.txt
model=$CSJ_ROOT/final.mdl
FST=$CSJ_ROOT/HCLG.fst
wav_rspecifier="ark,s,cs:wav-copy scp,p:$NNET3/wav.scp ark:- |"
# wav_rspecifier="ark,s,cs:extract-segments scp,p:$$CSJ_ROOT/wav.scp $$CSJ_ROOT/segments ark:- |"
spk2utt_rspecifier="ark:$CSJ_ROOT/spk2utt"

if [ "$post_decode_acwt" == 1.0 ]; then
	lat_wspecifier="ark:|gzip -c > work/lat.gz"
else
	lat_wspecifier="ark:|lattice-scale --acoustic-scale=$post_decode_acwt ark:- ark:- | gzip -c >$NNET3/lat.gz"
fi

if [ "$silence_weight" != "1.0" ]; then
	silphones=$(cat $CSJ_ROOT/phones/silence.csl) || exit 1;
	silence_weighting_opts="--ivector-silence-weighting.max-state-duration=$max_state_duration --ivector-silence-weighting.silence_phones=$silencephones --ivector-silence-weighting.silence-weighting=$silence_weight"
else
	silence_weighting_opts=
fi

online2-wav-nnet3-latgen-faster $silence_weighting_opts \
 --do-endpointing=$do_endpointing \
 --frames-per-chunk=$frames_per_chunk \
 --extra-left-context-initial=$extra_left_context_initial \
 --online=$online \
 $frame_subsampling_opt \
 --config=$online_config \
 --min-active=$min_active --max-active=$max_active --beam=$beam --lattice-beam=$lattice_beam \
 --acoustic-scale=$acwt --word-symbol-table=$symtable \
 $model $FST $spk2utt_rspecifier "$wav_rspecifier" \
 "$lat_wspecifier" 2> $NNET3/err.log

 lattice=$NNET3/lat.gz
 symtable=$CSJ_ROOT/words.txt
 symtable_nopos=$NNET3/words-nopos.txt
 spk="kaldiAudio"

 # lattice-copy "ark:gunzip -c $lattice|" ark:- | \
 lattice-scale --inv-acoustic-scale=10 "ark:gunzip -c $lattice|" ark:- | \
 lattice-add-penalty --word-ins-penalty=0.0 ark:- ark:- | \
 # lattice-prune --beam=$beam ark:- ark:- | \
 # lattice-mbr-decode --word-symbol-table=$symtable ark:- ark,t:word_ids
 lattice-best-path --word-symbol-table=$symtable ark:- ark,t:$NNET3/word_ids
 perl $NNET3/int2sym.pl -f 2- $symtable_nopos $NNET3/word_ids | tr -d "$spk " > $NNET3/result
