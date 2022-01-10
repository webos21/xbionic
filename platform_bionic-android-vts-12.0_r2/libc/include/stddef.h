/*
 * Copyright 2013 Cheolmin Jo (webos21@gmail.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// DUMMY : stddef.h

#ifndef _STDDEF_H
#define _STDDEF_H

#ifndef NULL
#	ifdef __cplusplus
#		define NULL 0                ///< Define the NULL to 0 on c plus plus
#	else // !__cplusplus
#		define NULL ((void *)0)      ///< Define the NULL to null-pointer on C
#	endif // __cplusplus
#endif // NULL

#ifndef _SIZE_T_DEFINED_
#define _SIZE_T_DEFINED_
#	if defined(_WIN64) || defined(__ARM64_ARCH_8__)
typedef unsigned long long  size_t;
#	else  // !defined(_WIN64) && !defined(__ARM64_ARCH_8__)
typedef unsigned int        size_t;
#	endif // defined(_WIN64) || defined(__ARM64_ARCH_8__)
#endif // !_SIZE_T_DEFINED_

#ifndef _PTRDIFF_T_DEFINED_
#define _PTRDIFF_T_DEFINED_
#	if defined(_WIN64) || defined(__ARM64_ARCH_8__)
typedef unsigned long long  ptrdiff_t;
#	else  // !defined(_WIN64) && !defined(__ARM64_ARCH_8__)
typedef unsigned int        ptrdiff_t;
#	endif // defined(_WIN64) || defined(__ARM64_ARCH_8__)
#endif // !_PTRDIFF_T_DEFINED_

#ifndef __WCHAR_TYPE__
#define __WCHAR_TYPE__ int
#endif
#ifndef __cplusplus
typedef __WCHAR_TYPE__ wchar_t;
#endif

#endif /* _STDDEF_H */
