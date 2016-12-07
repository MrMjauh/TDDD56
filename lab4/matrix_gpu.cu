// Matrix addition, CPU version
// gcc matrix_cpu.c -o matrix_cpu -std=c99

/*
answers

N = 2**6 = 64 is the turning point in gpu v cpu
block size 16*16 gave the best performance for us

coalescing
on N=2**10
Time 0.4686
Time 0.1143
*/

#include <stdio.h>

__global__
void add_matrix(float *a, float *b, float *c, int N)
{
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	int index = x + y*N;
	if (index < N*N) // allow allocating more threads than elements
		c[index] = a[index] + b[index];
}


void add_matrix_cpu(float *a, float *b, float *c, int N)
{
	for (int y=0; y < N; y++)
		for (int x=0; y < N; x++){
			int index = x + y*N;
			c[index] = a[index] + b[index];
		}
}

int main()
{
	const int N = 1<<10;
	const int blockSize = 16;
	const int size = N*N*sizeof(float);
	float t;

	float *a, *ad;
	float *b, *bd;
	float *c, *cd;

	a = new float[N*N];
	b = new float[N*N];
	c = new float[N*N];
	cudaMalloc( (void**)&ad, size );
	cudaMalloc( (void**)&bd, size );
	cudaMalloc( (void**)&cd, size );

	cudaEvent_t event0, event1;
	cudaEventCreate(&event0);
	cudaEventCreate(&event1);

	for (int i = 0; i < N; i++)
		for (int j = 0; j < N; j++)
		{
			a[i+j*N] = 10 + i;
			b[i+j*N] = (float)j / N;
		}

	cudaMemcpy( ad, a, size, cudaMemcpyHostToDevice );
	cudaMemcpy( bd, b, size, cudaMemcpyHostToDevice );

	dim3 dimBlock( blockSize, blockSize );
	dim3 dimGrid( N/blockSize, N/blockSize );

	cudaEventRecord(event0, 0);
	add_matrix<<< dimGrid, dimBlock >>>(ad, bd, cd, N);
	cudaEventRecord(event1, 0);

	cudaMemcpy( c, cd, size, cudaMemcpyDeviceToHost );

	cudaEventSynchronize(event0);
	cudaEventSynchronize(event1);
	cudaEventElapsedTime(&t, event0, event1);

	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			if (i==N-1 && N-32 < j)printf("%0.2f ", c[i+j*N]);
		}
		//printf("\n");
	}
	printf("\n");
	printf("Time %0.4f\n", t);
}
