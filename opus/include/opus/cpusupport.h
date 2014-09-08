/**
   @file cpusupport.h
*/
/*
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
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef OPUSTOOLS_CPUSUPPORT_H
# define OPUSTOOLS_CPUSUPPORT_H

/* We want to warn if we're built with SSE support, but running
   on a host without those instructions. Therefore we disable
   the query both if the compiler isn't supporting SSE, and on
   targets which are guaranteed to have SSE. */
# if !defined(__SSE__) || defined(_M_X64) || defined(__amd64__)
#  define query_cpu_support() 0
# else

#if defined WIN32 || defined _WIN32
#include <intrin.h>
static inline int query_cpu_support(void)
{
   int buffer[4];
   __cpuid(buffer, 1);
   return ((buffer[3] & (1<<25)) == 0) /*SSE*/
#  ifdef __SSE2__
        + ((buffer[3] & (1<<26)) == 0) /*SSE2*/
#  endif
       ;
}
#else
#include <cpuid.h>
static inline int query_cpu_support(void)
{
   unsigned int eax, ebx, ecx, edx=0;
   __get_cpuid(1, &eax, &ebx, &ecx, &edx);
   return ((edx & 1<<25) == 0) /*SSE*/
#ifdef __SSE2__
        + ((edx & 1<<26) == 0) /*SSE2*/
#endif
       ;
}
#endif

# endif
#endif
