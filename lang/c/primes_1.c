
/* gcc -std=c11 primes_1.c -o primes_1
 */

#define _GNU_SOURCE

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <errno.h>
#include <signal.h>
#include <unistd.h>

static volatile int running = 1;

static void SIGINT_handler(int dummy)
{
    running = 0;
}

struct prime_run {
	FILE* cache;
	uint64_t last;
	uint64_t slot;
	uint64_t slots;
	uint64_t* storage;
};

static inline int prime_store(struct prime_run* run, uint64_t prime, int cache)
{
	if (run->slot > run->slots) {
		run->slots *= 2;
		run->storage = realloc(
			run->storage,
			sizeof(*run->storage) * run->slots
		);
		if (!run->storage) {
			fprintf(stderr, "failed to grow the storage: %s\n",
				strerror(errno));
			return -1;
		}
		fprintf(stdout, "realloc@(%llu, %llu)\n",
			(long long unsigned int)run->slot,
			(long long unsigned int)run->slots
		);
	}
	run->last = run->storage[run->slot++] = prime;
	
	if (cache) {
		if (fprintf(run->cache, "%llu\n", (long long unsigned int)prime) < 0)
			return -1;
	}
	return 0;
}

static int prime_init(struct prime_run* run, const char* cache_path)
{
	memset(run, 0, sizeof(*run));
	
	int exists = access(cache_path, F_OK) == 0;
	
	run->slots = 4096;
	run->storage = malloc(sizeof(*run->storage) * run->slots);
	if (!(run->cache = fopen(cache_path, exists? "r+": "w"))) {
		fprintf(stderr, "failed to open cache file: %s\n",
			strerror(errno));
		return -1;
	}
	
	if (exists) {
		char* line = NULL;
		size_t length = 0;
		while (getline(&line, &length, run->cache) > 0 && running) {
			errno = 0;
			uint64_t prime = strtoull(line, NULL, 10);
			if (errno) {
				fprintf(stderr, "strange prime line found\n");
				return -1;
			} else if (!prime) {
				break;
			}
			
			if (prime_store(run, prime, 0) != 0)
				return -1;
			
			free(line);
			line = NULL;
			length = 0;
		}
	} else {
		prime_store(run, 2, 1);
	}
	
	signal(SIGINT, SIGINT_handler);
	
	return 0;
}

static int prime_search(struct prime_run* run)
{
	for (uint64_t i = run->last + 1; i < UINT64_MAX && running; i++) {
		uint64_t prime = 1;
		for (
			uint64_t j = 0;
			j < run->slot &&
				run->storage[j] * run->storage[j] <= i &&
				running;
			j++
		) {
			if (i % run->storage[j] == 0) {
				prime = 0;
				break;
			}
		}
		if (prime) {
			if (prime_store(run, i, 1) != 0)
				return -1;
		}
	}
	return 0;
}

int main(int argc, char* argv[])
{
	struct prime_run run;
	
	if (prime_init(&run, "./primes.txt") != 0) {
		fprintf(stderr, "init failed\n");
		exit(EXIT_FAILURE);
	}
	
	fprintf(stdout, "starting search...\n");
	
	if (prime_search(&run) != 0) {
		fprintf(stderr, "search failed\n");
		exit(EXIT_FAILURE);
	}
	
	exit(EXIT_SUCCESS);
}

