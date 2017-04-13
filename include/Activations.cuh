#ifndef ACTIVATIONS_CUH_
#define ACTIVATIONS_CUH_

enum Activation{SOFTMAX,TANH,RELU,ELU,LINEAR,LOGISTIC};

__global__ void launch_activations_on_gpu(float *x, int numElems, Activation a);
__global__ void launch_gradients_on_gpu(float *x, Activation a, int numElems, float *delta);

__device__ void select_activation(float x, Activation a);
__device__ void select_gradient(float x, Activation a);

void activations_on_gpu(float *x, int numElems,Activation a);
void gradient_on_gpu(float *x, int numElems, Activation a, float *delta);


#endif
