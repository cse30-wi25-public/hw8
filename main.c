#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>

// #define N 10000000  // Array size
#define MAX_THREADS 4

double *arr;  // Shared array
double partial_sum[MAX_THREADS] = {0.0};  // Store partial results per thread
int num_threads;  // Number of active threads

int N; //Array size
int m; //Modular base
int s; //Scale factor

// Timer function
double get_time() {
    struct timeval t;
    gettimeofday(&t, NULL);
    return t.tv_sec + t.tv_usec * 1e-6;
}

// Serial work (non-parallelizable)
void serial_work(int N, int m) {
    arr[0] = 1;
    arr[1] = 1;
    for (int i = 2; i < N; i++) {
        arr[i] = ((int) (arr[i-2] + arr[i-1]) % m);
    }
}

// Parallel work function (executed by threads)
void *parallel_work(void *arg) {
    int thread_id = *(int *)arg;


    //// TODO: Calculate start and end indices for each thread

    ////

    double sum = 0.0;
    
    //// TODO: Compute sum of array elements assigned to this thread

    ////

    //// TODO: Store partial sum in the global array

    ////

    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 4){
        fprintf(stderr, "%s : Needs 3 arguments\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    N = atoi(argv[1]); //Array size
    m = atoi(argv[2]); //Modular base
    s = atoi(argv[3]); //Scale factor

    if ((N % 4) != 0){
        fprintf(stderr, "N must be divided by 4\n");
        exit(EXIT_FAILURE);
    }

    if ((N < 10000000) || (N > 100000000)){
        fprintf(stderr, "N must be 10,000,000 <= N 100,000,000\n");
        exit(EXIT_FAILURE);
    }

    if (m <= 1){
        fprintf(stderr, "m must be a positive integer greater than 1\n");
        exit(EXIT_FAILURE);
    }

    arr = (double *)malloc(N * sizeof(double));
    
    double T1, TN;

    // Test with different thread counts
    for (num_threads = 1; num_threads <= MAX_THREADS; num_threads *= 2) {
        pthread_t threads[num_threads];
        int thread_ids[num_threads];

        // Start timing
        double start_time = get_time();

       // Call serial section
       serial_work(N, m);
        
        //// TODO: Create threads and execute parallel_work function (Hint: use pthread_create)

        ////

        //// TODO: Join threads after execution (Hint: use pthread_join)

        ////

        // Aggregate results
        double total_sum = 0.0;

        //// TODO: Sum up the partial results from all threads

        ////

        // End timing
        double end_time = get_time();
        TN = end_time - start_time;

        if (num_threads == 1) {
            T1 = TN;
        }

        // Calculate speedup
        double speedup = T1 / TN;
        printf("Total sum: %f, Threads: %d, Time: %f sec, Speedup: %f\n", total_sum, num_threads, TN, speedup);
    }

    free(arr);
    return 0;
}

