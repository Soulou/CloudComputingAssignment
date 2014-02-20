/*
 * @File : matrix_multiply.c
 *
 * @Author : Léo Unbekandt
 *
 * @Summary : MPI multiplication of 2 matrices
 *
 * @Version : 2014/02/18
 *
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * Léo Unbekandt wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return 
 * ----------------------------------------------------------------------------
 */

#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

void usage() {
  printf("matrix_multiply <matrix 1> <matrix 2> <output>");
  MPI_Abort(MPI_COMM_WORLD, 1);
  exit(1);
}

struct matrix {
  double ** data;
  int nrows;
  int ncols;
};

typedef struct matrix Matrix;

Matrix * matrix_from_file(FILE * f);
Matrix * matrix_new(int nr, int nc);
void matrix_free(Matrix * m);
void matrix_dump(Matrix * m, FILE * f);
void matrix_print(Matrix * m);

int main(int argc, char *argv[]) {
  MPI_Init(&argc, &argv);
  int rank, nnodes;
  
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &nnodes);

  double start_time, end_time;
  Matrix *m1, *m2, *mout;
  int m2nrows, m2ncols, m1nrows, m1ncols;
  if(rank == 0) {
    if(argc != 4) {
      usage();
    }

    FILE * f1 = fopen(argv[1], "r");
    if(f1 == NULL) {
      printf("Invalid file \"%s\"\n", argv[1]);
      usage();
    }
    FILE * f2 = fopen(argv[2], "r");
    if(f2 == NULL) {
      printf("Invalid file \"%s\"\n", argv[2]);
      usage();
    }

    m1 = matrix_from_file(f1);
    m2 = matrix_from_file(f2);

    m1ncols = m1->ncols;
    m1nrows = m1->nrows;
    m2ncols = m2->ncols;
    m2nrows = m2->nrows;

    if(m1->ncols != m2->nrows) {
      printf("Dimension of matrices should be A×B and B×C, they are %d×%d and %d×%d\n",
          m1->nrows, m1->ncols, m2->nrows, m2->ncols);
      usage();
    }

    mout = matrix_new(m1->nrows, m2->ncols);
  }

  MPI_Bcast(&m1nrows, 1, MPI_INT, 0, MPI_COMM_WORLD);
  MPI_Bcast(&m1ncols, 1, MPI_INT, 0, MPI_COMM_WORLD);
  MPI_Bcast(&m2nrows, 1, MPI_INT, 0, MPI_COMM_WORLD);
  MPI_Bcast(&m2ncols, 1, MPI_INT, 0, MPI_COMM_WORLD);

  int offset, nelem, i, j, k;
  int sstrip = m1nrows / nnodes;

  if(rank != 0) {
    m1 = matrix_new(sstrip, m1ncols);
    m2 = matrix_new(m2nrows, m2ncols);
    mout = matrix_new(sstrip, m2ncols);
  }

  if(rank == 0) {
    start_time = MPI_Wtime();
  }

  if(rank == 0) {
    // rank 0 also coputes, so it keeps the first strip
    offset = sstrip;
    nelem = sstrip * m1->ncols;
    for(i = 1; i < nnodes; i++) {
      MPI_Send(m1->data[offset], nelem, MPI_DOUBLE, i, 0, MPI_COMM_WORLD);
      offset += sstrip;
    }
  } else {
    MPI_Recv(m1->data[0], sstrip * m1ncols, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
  }
  MPI_Bcast(m2->data[0], m2nrows * m2ncols, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  for (i = 0; i < sstrip; i++) {
    for (j = 0; j < m2ncols; j++) {
      for (k = 0; k < m1ncols; k++) {
        mout->data[i][j] += m1->data[i][k] * m2->data[k][j];
      }
    }
  }

  offset = rank * sstrip;
  MPI_Gather(mout->data[0], sstrip * m2ncols, MPI_DOUBLE, mout->data[0], sstrip * m2ncols, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  if (rank == 0) {
    end_time = MPI_Wtime();
    FILE * f = fopen(argv[3], "w");
    if(f == NULL) {
      printf("Fail to open %s\n", argv[2]);
    } else {
      fprintf(f, "%lf\n", end_time - start_time);
      matrix_dump(mout, f);
      fclose(f);
    }
  }
  
  matrix_free(m1);
  matrix_free(m2);
  matrix_free(mout);
  MPI_Finalize();
  return 0;
}


Matrix * matrix_from_file(FILE * f) {
  int i, j;
  Matrix * m = (Matrix *)malloc(sizeof(Matrix));
  fscanf(f, "%d\n%d\n", &m->nrows, &m->ncols);

  // Everything is allocated continuously
  double * tmp = (double *)malloc(sizeof(double) * m->ncols * m->nrows);
  m->data = (double **)malloc(sizeof(double *) * m->nrows);
  for(i = 0; i < m->nrows; i++) {
    m->data[i] = &tmp[m->ncols * i];
    for(j = 0; j < m->ncols; j++) {
      fscanf(f, "%lf\n", &m->data[i][j]);
    }
  }
  
  return m;
}

Matrix * matrix_new(int nr, int nc) {
  int i, j;
  Matrix * m = (Matrix *)malloc(sizeof(Matrix));
  m->nrows = nr;
  m->ncols = nc;

  double * tmp = (double *)malloc(sizeof(double) * m->ncols * m->nrows);
  m->data = (double **)malloc(sizeof(double *) * m->nrows);
  for(i = 0; i < m->nrows; i++) {
    m->data[i] = &tmp[m->ncols * i];
    for(j = 0; j < m->ncols; j++) {
      m->data[i][j] = 0.0;
    }
  }
  return m;
}

void matrix_free(Matrix * m) {
  if(m == NULL) return;
  free(m->data[0]);
  free(m->data);
  free(m);
}

void matrix_print(Matrix * m) {
  if(m == NULL) { printf("Matrix NULL\n"); return; }
  printf("Nrows: %d | Ncols: %d\n", m->nrows, m->ncols);
  
  int i, j;
  for(i = 0 ; i < m->nrows; i++) {
    for(j = 0; j < m->ncols; j++) {
      printf("%lf ", m->data[i][j]);
    }
    printf("\n");
  }
  printf("\n");
}

void matrix_dump(Matrix * m, FILE * f) {
  int i, j;
  fprintf(f, "%d\n%d\n", m->nrows, m->ncols);

  for(i = 0; i < m->nrows; i++) {
    for(j = 0 ; j < m->ncols ; j++) {
      fprintf(f, "%lf\n", m->data[i][j]);
    }
  }
}
