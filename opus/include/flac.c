/*Copyright 2012-2013, Xiph.Org Foundation and contributors.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  - Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  - Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*/
#if defined(HAVE_CONFIG_H)
# include <config.h>
#endif
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <locale.h>
#include "flac.h"
#include "opus_header.h"
#include "picture.h"

#if defined(HAVE_LIBFLAC)

/*Callback to read more data for the FLAC decoder.*/
static FLAC__StreamDecoderReadStatus read_callback(
   const FLAC__StreamDecoder *decoder,FLAC__byte buffer[],size_t *bytes,
   void *client_data){
  flacfile *flac;
  (void)decoder;
  flac=(flacfile *)client_data;
  if(*bytes>0){
    int bufpos;
    int buflen;
    bufpos=flac->bufpos;
    buflen=flac->buflen;
    if(bufpos<buflen){
      size_t bytes_to_copy;
      /*If we haven't consumed all the data we used for file ID yet, consume
        some more.*/
      bytes_to_copy=buflen-bufpos;
      bytes_to_copy=*bytes<bytes_to_copy?*bytes:bytes_to_copy;
      memcpy(buffer,flac->oldbuf,bytes_to_copy);
      flac->bufpos+=bytes_to_copy;
      *bytes=bytes_to_copy;
    }else{
      /*Otherwise just read from the file.*/
      *bytes=fread(buffer,sizeof(*buffer),*bytes,flac->f);
    }
    /*This pretty much comes from the FLAC documentation, except that we only
      check ferror() if we didn't read any bytes at all.*/
    return *bytes==0?ferror(flac->f)?
       FLAC__STREAM_DECODER_READ_STATUS_ABORT:
       FLAC__STREAM_DECODER_READ_STATUS_END_OF_STREAM:
       FLAC__STREAM_DECODER_READ_STATUS_CONTINUE;
  }
  return FLAC__STREAM_DECODER_READ_STATUS_ABORT;
}

/*Callback to test the stream for EOF.*/
static FLAC__bool eof_callback(const FLAC__StreamDecoder *decoder,
   void *client_data){
  flacfile *flac;
  (void)decoder;
  flac=(flacfile *)client_data;
  return feof(flac->f)?true:false;
}

/*Callback to process a metadata packet.*/
static void metadata_callback(const FLAC__StreamDecoder *decoder,
   const FLAC__StreamMetadata *metadata,void *client_data){
  flacfile *flac;
  oe_enc_opt *inopt;
  (void)decoder;
  flac=(flacfile *)client_data;
  inopt=flac->inopt;
  switch(metadata->type){
    case FLAC__METADATA_TYPE_STREAMINFO:
      flac->max_blocksize=metadata->data.stream_info.max_blocksize;
      inopt->rate=metadata->data.stream_info.sample_rate;
      inopt->channels=flac->channels=metadata->data.stream_info.channels;
      inopt->samplesize=metadata->data.stream_info.bits_per_sample;
      inopt->total_samples_per_channel=
         metadata->data.stream_info.total_samples;
      flac->block_buf=malloc(
         flac->max_blocksize*flac->channels*sizeof(*flac->block_buf));
      flac->block_buf_pos=0;
      flac->block_buf_len=0;
      break;
    case FLAC__METADATA_TYPE_VORBIS_COMMENT:
      {
        FLAC__StreamMetadata_VorbisComment_Entry *comments;
        FLAC__uint32 num_comments;
        FLAC__uint32 i;
        double reference_loudness;
        double album_gain;
        double track_gain;
        double gain;
        int saw_album_gain;
        int saw_track_gain;
        char *saved_locale;
        if(!inopt->copy_comments)break;
        num_comments=metadata->data.vorbis_comment.num_comments;
        comments=metadata->data.vorbis_comment.comments;
        saw_album_gain=saw_track_gain=0;
        album_gain=track_gain=0;
        /*The default reference loudness for ReplayGain is 89.0 dB*/
        reference_loudness=89;
        /*The code below uses strtod for the gain tags, so make sure the locale is C*/
        saved_locale=setlocale(LC_NUMERIC,"C");
        for(i=0;i<num_comments;i++){
          char *entry;
          char *end;
          entry=(char *)comments[i].entry;
          /*Check for ReplayGain tags.
            Parse the ones we have R128 equivalents for, and skip the others.*/
          if(oi_strncasecmp(entry,"REPLAYGAIN_REFERENCE_LOUDNESS=",30)==0){
            gain=strtod(entry+30,&end);
            if(end<=entry+30){
              fprintf(stderr,_("WARNING: Invalid ReplayGain tag: %s\n"),entry);
            }
            else reference_loudness=gain;
            continue;
          }
          if(oi_strncasecmp(entry,"REPLAYGAIN_ALBUM_GAIN=",22)==0){
            gain=strtod(entry+22,&end);
            if(end<=entry+22){
              fprintf(stderr,_("WARNING: Invalid ReplayGain tag: %s\n"),entry);
            }
            else{
              album_gain=gain;
              saw_album_gain=1;
            }
            continue;
          }
          if(oi_strncasecmp(entry,"REPLAYGAIN_TRACK_GAIN=",22)==0){
            gain=strtod(entry+22,&end);
            if(end<entry+22){
              fprintf(stderr,_("WARNING: Invalid ReplayGain tag: %s\n"),entry);
            }
            else{
              track_gain=gain;
              saw_track_gain=1;
            }
            continue;
          }
          if(oi_strncasecmp(entry,"REPLAYGAIN_ALBUM_PEAK=",22)==0
             ||oi_strncasecmp(entry,"REPLAYGAIN_TRACK_PEAK=",22)==0){
            continue;
          }
          if(!strchr(entry,'=')){
            fprintf(stderr,_("WARNING: Invalid comment: %s\n"),entry);
            fprintf(stderr,
               _("Discarding comment not in the form name=value\n"));
            continue;
          }
          comment_add(&inopt->comments,&inopt->comments_length,NULL,entry);
        }
        setlocale(LC_NUMERIC,saved_locale);
        /*Set the header gain to the album gain after converting to the R128
          reference level.*/
        if(saw_album_gain){
          gain=256*(album_gain+(84-reference_loudness))+0.5;
          inopt->gain=gain<-32768?-32768:gain<32767?(int)floor(gain):32767;
        }
        /*If there was a track gain, then add an equivalent R128 tag for that.*/
        if(saw_track_gain){
          char track_gain_buf[7];
          int track_gain_val;
          gain=256*(track_gain-album_gain)+0.5;
          track_gain_val=gain<-32768?-32768:gain<32767?(int)floor(gain):32767;
          sprintf(track_gain_buf,"%i",track_gain_val);
          comment_add(&inopt->comments,&inopt->comments_length,
             "R128_TRACK_GAIN",track_gain_buf);
        }
      }
      break;
    case FLAC__METADATA_TYPE_PICTURE:
      {
        char  *buf;
        char  *b64;
        size_t mime_type_length;
        size_t description_length;
        size_t buf_sz;
        size_t b64_sz;
        size_t offs;
        if(!inopt->copy_pictures)break;
        mime_type_length=strlen(metadata->data.picture.mime_type);
        description_length=strlen((char *)metadata->data.picture.description);
        buf_sz=32+mime_type_length+description_length
         +metadata->data.picture.data_length;
        buf=(char *)malloc(buf_sz);
        offs=0;
        WRITE_U32_BE(buf+offs,metadata->data.picture.type);
        offs+=4;
        WRITE_U32_BE(buf+offs,(FLAC__uint32)mime_type_length);
        offs+=4;
        memcpy(buf+offs,metadata->data.picture.mime_type,mime_type_length);
        offs+=mime_type_length;
        WRITE_U32_BE(buf+offs,(FLAC__uint32)description_length);
        offs+=4;
        memcpy(buf+offs,metadata->data.picture.description,description_length);
        offs+=description_length;
        WRITE_U32_BE(buf+offs,metadata->data.picture.width);
        offs+=4;
        WRITE_U32_BE(buf+offs,metadata->data.picture.height);
        offs+=4;
        WRITE_U32_BE(buf+offs,metadata->data.picture.depth);
        offs+=4;
        WRITE_U32_BE(buf+offs,metadata->data.picture.colors);
        offs+=4;
        WRITE_U32_BE(buf+offs,metadata->data.picture.data_length);
        offs+=4;
        memcpy(buf+offs,metadata->data.picture.data,
           metadata->data.picture.data_length);
        b64_sz=BASE64_LENGTH(buf_sz)+1;
        b64=(char *)malloc(b64_sz);
        base64_encode(b64,buf,buf_sz);
        free(buf);
        comment_add(&inopt->comments,&inopt->comments_length,
           "METADATA_BLOCK_PICTURE",b64);
        free(b64);
      }
      break;
    default:
      break;
  }
}

/*Callback to process an audio frame.*/
static FLAC__StreamDecoderWriteStatus write_callback(
   const FLAC__StreamDecoder *decoder,const FLAC__Frame *frame,
   const FLAC__int32 *const buffer[],void *client_data){
  flacfile *flac;
  int channels;
  opus_int32 blocksize;
  int bits_per_sample;
  float scale;
  const int *channel_permute;
  float *block_buf;
  int ci;
  opus_int32 si;
  (void)decoder;
  flac=(flacfile *)client_data;
  /*We do not allow the number of channels to change.*/
  channels=frame->header.channels;
  if(channels!=flac->channels){
    return FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
  }
  /*We do not allow block sizes larger than the declared maximum.*/
  blocksize=frame->header.blocksize;
  if(blocksize>flac->max_blocksize){
    return FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
  }
  /*We do allow the bits per sample to change, though this will confound Opus's
    silence detection.*/
  bits_per_sample=frame->header.bits_per_sample;
  speex_assert(bits_per_sample>0&&bits_per_sample<=32);
  scale=(0x80000000U>>(bits_per_sample-1))*(1.0F/0x80000000U);
  channel_permute=flac->channel_permute;
  block_buf=flac->block_buf;
  for(ci=0;ci<channels;ci++){
    const FLAC__int32 *channel_buf;
    channel_buf=buffer[channel_permute[ci]];
    for(si=0;si<blocksize;si++){
      /*There's a loss of precision here for 32-bit samples, but libFLAC
        doesn't currently support more than 24.*/
      block_buf[si*channels+ci]=scale*(float)channel_buf[si];
    }
  }
  flac->block_buf_pos=0;
  flac->block_buf_len=blocksize;
  return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

/*Dummy error callback (required by libFLAC).*/
static void error_callback(const FLAC__StreamDecoder *decoder,
   FLAC__StreamDecoderErrorStatus status,void *client_data){
  (void)decoder;
  (void)status;
  (void)client_data;
}

int flac_id(unsigned char *buf,int len){
  /*Something screwed up.*/
  if(len<4)return 0;
  /*Not FLAC.*/
  if(memcmp(buf,"fLaC",4))return 0;
  /*Looks like FLAC.*/
  return 1;
}

int oggflac_id(unsigned char *buf,int len){
  /*Something screwed up.*/
  if(len<33)return 0;
  /*Not Ogg.*/
  if(memcmp(buf,"OggS",4))return 0;
  /*Not FLAC.*/
  if(memcmp(buf+28,"\177FLAC",5))return 0;
  /*Looks like OggFLAC.*/
  return 1;
}

/*Read more data for the encoder.*/
static long flac_read(void *client_data,float *buffer,int samples){
  flacfile *flac;
  int channels;
  float *block_buf;
  long ret;
  flac=(flacfile *)client_data;
  channels=flac->channels;
  block_buf=flac->block_buf;
  ret=0;
  /*Keep reading until we get all the samples or hit an error/EOF.
    Short reads are not allowed.*/
  while(samples>0){
    opus_int32 block_buf_pos;
    opus_int32 block_buf_len;
    size_t samples_to_copy;
    block_buf_pos=flac->block_buf_pos;
    block_buf_len=flac->block_buf_len;
    if(block_buf_pos>=block_buf_len){
      /*Read the next frame from the stream.*/
      if(!FLAC__stream_decoder_process_single(flac->decoder))return ret;
      block_buf_pos=flac->block_buf_pos;
      block_buf_len=flac->block_buf_len;
      /*If we didn't get another block, we hit EOF.
        FLAC__stream_decoder_process_single still returns successfully in this
        case.*/
      if(block_buf_pos>=block_buf_len)return ret;
    }
    block_buf_len-=block_buf_pos;
    samples_to_copy=samples<block_buf_len?samples:block_buf_len;
    memcpy(buffer,block_buf+block_buf_pos*channels,
       samples_to_copy*channels*sizeof(*buffer));
    flac->block_buf_pos+=samples_to_copy;
    ret+=samples_to_copy;
    buffer+=samples_to_copy*channels;
    samples-=samples_to_copy;
  }
  return ret;
}

int flac_open(FILE *in,oe_enc_opt *opt,unsigned char *oldbuf,int buflen){
  flacfile *flac;
  /*Ok. At this point, we know we have a FLAC or an OggFLAC file.
    Set up the FLAC decoder.*/
  flac=malloc(sizeof(*flac));
  flac->decoder=FLAC__stream_decoder_new();
  FLAC__stream_decoder_set_md5_checking(flac->decoder,false);
  /*We get STREAMINFO packets by default, but not VORBIS_COMMENT or PICTURE.*/
  FLAC__stream_decoder_set_metadata_respond(flac->decoder,
     FLAC__METADATA_TYPE_VORBIS_COMMENT);
  FLAC__stream_decoder_set_metadata_respond(flac->decoder,
     FLAC__METADATA_TYPE_PICTURE);
  flac->inopt=opt;
  flac->f=in;
  flac->oldbuf=malloc(buflen*sizeof(*flac->oldbuf));
  memcpy(flac->oldbuf,oldbuf,buflen*sizeof(*flac->oldbuf));
  flac->bufpos=0;
  flac->buflen=buflen;
  flac->block_buf=NULL;
  if((*(flac_id(oldbuf,buflen)?
     FLAC__stream_decoder_init_stream:FLAC__stream_decoder_init_ogg_stream))(
        flac->decoder,read_callback,NULL,NULL,NULL,eof_callback,
        write_callback,metadata_callback,error_callback,flac)==
     FLAC__STREAM_DECODER_INIT_STATUS_OK){
    /*Decode until we get the file length, sample rate, the number of channels,
      and the Vorbis comments (if any).*/
    if(FLAC__stream_decoder_process_until_end_of_metadata(flac->decoder)){
      opt->read_samples=flac_read;
      opt->readdata=flac;
      /*FLAC supports 1 to 8 channels only.*/
      speex_assert(flac->channels>0&&flac->channels<=8);
      /*It uses the same channel mappings as WAV.*/
      flac->channel_permute=wav_permute_matrix[flac->channels-1];
      return 1;
    }
  }
  flac_close(flac);
  fprintf(stderr,_("ERROR: Could not open FLAC stream.\n"));
  return 0;
}

void flac_close(void *client_data){
  flacfile *flac;
  flac=(flacfile *)client_data;
  free(flac->block_buf);
  free(flac->oldbuf);
  FLAC__stream_decoder_delete(flac->decoder);
  free(flac);
}

#else

/*FLAC support is disabled.*/

int flac_id(unsigned char *buf,int len){
  (void)buf;
  (void)len;
  return 0;
}

int oggflac_id(unsigned char *buf,int len){
  (void)buf;
  (void)len;
  return 0;
}

int flac_open(FILE *in,oe_enc_opt *opt,unsigned char *oldbuf,int buflen){
  (void)in;
  (void)opt;
  (void)oldbuf;
  (void)buflen;
  return 0;
}

void flac_close(void *client_data){
  (void)client_data;
}

#endif
