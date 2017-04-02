#ifndef GPMATRIX_HPP_
#define GPMATRIX_HPP_ 

#include <cuda.h>
#include <cublas_v2.h>
#include <helper_cuda.h>

#define cudaCheckError() __cudaCheckError(__FILE__,__LINE__)
#define cudaSafeCall(err) __cudaSafeCall(err,__FILE__,__LINE__)

inline void __cudaSafeCall(cudaError err,const char*file,const int line) {
   if(cudaSuccess != err) {
    fprintf(stderr,"cudaSafeCall() failed at %s:%i: %s\n",file,line,cudaGetErrorString(err));
    exit(-1);
   }
 }

inline void __cudaCheckError(const char*file,const int line) {
   cudaError err = cudaGetLastError();
   if(cudaSuccess != err) {
      printf("cudaCheckError() failed at %s:%i :%s \n", file,line,cudaGetErrorString(err));
      exit(-1);
    }
  }


/*
 GpMatrix: Class encapsulating the behavior of the 
 CUDA matrix datatype. 

 Adds functions to use with the GpMatrix object.

 Note: In cuBLAS the matrices are in COLUMN major and in C++
 the matrices are in row major.
 so GpMatrix = Matrix'

 Note 1: This matrix is supposed to mimic a matrix on the device. 
 It contains functions that you can usually perform on a matrix.

 For operations on gpMatrix, refer gpMatrix_util.c{u,uh}
 For kernels refer to gpMatrixkernels. 

 */
class GpMatrix
{ 
 private:
  double *_deviceData; // device data
  int _numRows, _numCols;
  int _n_elem;
  bool _isTrans;
  int stride; 
  void _initGpMatrix(int numRows, int numCols, int stride, bool isTrans);
  static void cuBlaserrcheck(const char *msg) {
  	 cuBlasStatus_t stat = cublasGetError();
  	 if (stat != CUBLAS_STATUS_SUCCESS)
  	 {
  	 	fprintf(stderr, msg,NULL);
  	 	exit(1);
  	 }

  }
  

public:
   GpMatrix();
   GpMatrix(double *dev_data, int numRows, int numCols, int stride, bool isTrans);
   ~GpMatrix();
   static int getDeviceID();

   bool checkeqDims(const Matrix &mat) const {
   	return mat.getnumRows() == _numRows && mat.getNumCols() == _numCols;
   }
  
   int getnumRows() const {
   	 return _numRows;
   }

   int getnumCols() const {
   	  return _numCols;
   }


   int getnumElements() const {
   	 return _numElements;
   }

   double *getDevData() const {
   	return _deviceData;
   }

   double* getoneCell(int i, int j) const{
       if(_isTrans)
       	return &_deviceData[j*_numRows+i];
       else
       	retunr &_deviceData[i*_numRows+j];
   }

   int getStride() const {
     return stride;
   }

   int getLeadingDim(GpMatrix &gp) const {
   	 return _isTrans ? _numRows : _numCols;
   }
   
   int getFollowingDim(GpMatrix &gp) const {
     return _isTrans? _numCols: _numRows;   
 }
  
  bool checkContiguous() const {
  	stride == getLeadingDim() || getFollowingDim() == 1; // for vectors. 
  }
   // void makeTrans(bool trans){
   // 	 if (trans != _isTrans)
   // 	 {  
   // 	 	trans = isTrans;
   // 	 }
   // }
void checkEqual(const GpMatrix &a, const GpMatrix &b) const; // check if matrices are equal
void cpfromHost(Matrix &hostMat) const; 
void cptoHost(Matrix & mat) const; //copy the gpmatrix to the host matrix.

// void template<class Uopertor> applyUoperator(Uoperator op, GpMatrix & a); // perform unaryoperator on the specified matrix
// void template<class Boperator> applyBoperator(Boperator op, GpMatrix &a, GpMatrix &b); // perform binary operation on the specified matrices.
void resize(int Rows, int Cols); // resize the matrix according to the given dimensions.
void matCheckBounds(int numRows, int numCols) const;

bool checkContiguous(const GpMatrix &mat); // check if a GpMatrix is continguous.
GpMatrix & sliceRow(int rowStart, int rowEnd) const; 
GpMatrix & sliceCol(int colStart, int colEnd) const;
GpMatrix & slice(int rowStart, int colStart, int rowEnd, int colEnd) const; // matrix slice operations. Return a new GpMatrix after slice.
GpMatrix & reshape(int Rows, int Cols); // reshape the matrix acc to the args

void transposeMat(GpMatrix &tgt); // return the transpose of the matrix.
void printShape(int numRows, int numCols); // print the shape of the Matrix.
	
};


#endif