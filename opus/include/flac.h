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
#ifndef __FLAC_H
# define __FLAC_H
# include <stdio.h>
# include "os_support.h"
# include "opusenc.h"
# if defined(HAVE_LIBFLAC)
#  include <FLAC/stream_decoder.h>
#  include <FLAC/metadata.h>

typedef struct flacfile flacfile;

struct flacfile{
  FLAC__StreamDecoder *decoder;
  oe_enc_opt *inopt;
  short channels;
  FILE *f;
  const int *channel_permute;
  unsigned char *oldbuf;
  int bufpos;
  int buflen;
  float *block_buf;
  opus_int32 block_buf_pos;
  opus_int32 block_buf_len;
  opus_int32 max_blocksize;
};

# endif

int flac_id(unsigned char *buf,int len);
int oggflac_id(unsigned char *buf,int len);
int flac_open(FILE *in,oe_enc_opt *opt,unsigned char *oldbuf,int buflen);
void flac_close(void *client_data);

#endif
