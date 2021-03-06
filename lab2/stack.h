/*
 * stack.h
 *
 *  Created on: 18 Oct 2011
 *  Copyright 2011 Nicolas Melot
 *
 * This file is part of TDDD56.
 *
 *     TDDD56 is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     TDDD56 is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with TDDD56. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <stdlib.h>
#include <pthread.h>

#ifndef STACK_H
#define STACK_H

#define CAS(a,b,c) (cas((size_t*)(a),(size_t)(b),(size_t)(c))!=(size_t)(b))

typedef struct stack_node
{
  int elem;
  struct stack_node *next;
} stack_node_t;

typedef struct stack
{
  struct stack_node *head;
#if NON_BLOCKING == 0
  pthread_mutex_t lock;
#endif
} *stack_t, stack_head_t;

// Pushes an element in a thread-safe manner
void
stack_push(stack_t s, struct stack_node *node);

// Pops an element in a thread-safe manner
struct stack_node *
stack_pop(stack_t s);

/* Debug practice: check the boolean expression expr; if it computes to 0, print a warning message on standard error and exit */

// If a default assert is already defined, undefine it first
#ifdef assert
#undef assert
#endif

// Enable assert() only if NDEBUG is not set
#ifndef NDEBUG
#define assert(expr) if(!(expr)) { fprintf(stderr, "[%s:%s:%d][ERROR] Assertion failure: %s\n", __FILE__, __FUNCTION__, __LINE__, #expr); abort(); }
#else
// Otherwise define it as nothing
#define assert(expr)
#endif

// Debug practice: function that can check anytime is a stack is in a legal state using assert() internally
void
stack_check(stack_t stack);

#endif /* STACK_H */
