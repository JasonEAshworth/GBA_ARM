#define _CRT_SECURE_NO_WARNINGS

#include <Windows.h>
#include <cstdlib>
#include <cmath>

#include <iostream>
#include <vector>
using namespace std;

#include <include/SDL.h>
#include <include/SDL_image.h>

#include <cl.h>

#define SCREEN_WIDTH 1280
#define SCREEN_HEIGHT 480
#define IMAGE_FILE "mario.png"

typedef struct {
	cl_context context;
	cl_command_queue queue;
	cl_program program;
	cl_kernel kernel;
	char *kernelFunctionName;
	char *sourceFile;
} OpenCLData;

bool InitOpenCL( OpenCLData &oclData );
void CleanupOpenCL( OpenCLData &oclData );
void SobelCL( SDL_Surface *surface, OpenCLData &oclData );
void BlurImageCL( SDL_Surface *surface, int kernSize, OpenCLData &oclData );
void GrayImage( SDL_Surface *surface );
void Sobel( SDL_Surface *surface );

int main( int argc, char **argv ) {
	if ( SDL_Init( SDL_INIT_VIDEO ) ) {
		MessageBox( NULL, L"Error initializing SDL!", L"Error", MB_OK | MB_ICONERROR );
		exit( EXIT_FAILURE );
	}
	
	SDL_Surface *surface = SDL_SetVideoMode( SCREEN_WIDTH, SCREEN_HEIGHT, 32, SDL_HWSURFACE | SDL_DOUBLEBUF );
	if ( !surface ) {
		MessageBox( NULL, L"Error creating SDL surface!", L"Error", MB_OK | MB_ICONERROR );
		exit( EXIT_FAILURE );
	}

	
	OpenCLData oclData;
	oclData.kernelFunctionName = "Blur";
	oclData.sourceFile = "blur.cl";
	if ( !InitOpenCL( oclData ) ) {
		MessageBox( NULL, L"Error compiling OpenCL program!", L"Error", MB_OK | MB_ICONERROR );
		exit( EXIT_FAILURE );
	}
	
	

	SDL_Surface *inputImage = IMG_Load( IMAGE_FILE );
	if (!inputImage) {
		MessageBox( NULL, L"Error loading image!", L"Error", MB_OK | MB_ICONERROR );
		exit( EXIT_FAILURE );
	}

	SDL_Rect rect = { 0, 0 };
	SDL_BlitSurface( inputImage, NULL, surface, &rect );

	SDL_Surface *tmpImage = SDL_CreateRGBSurface( SDL_SWSURFACE,
		inputImage->w, inputImage->h, 32, 0, 0, 0, 0);
	SDL_BlitSurface( inputImage, NULL, tmpImage, NULL );

	//SobelCL( tmpImage,  oclData );
	BlurImageCL( tmpImage, 3, oclData );
	rect.x += inputImage->w;
	SDL_BlitSurface( tmpImage, NULL, surface, &rect );

	SDL_FreeSurface( tmpImage );

	GrayImage( inputImage );
	rect.x += inputImage->w;
	SDL_BlitSurface( inputImage, NULL, surface, &rect );

	Sobel( inputImage );
	rect.x += inputImage->w;
	SDL_BlitSurface( inputImage, NULL, surface, &rect );

	SDL_Flip( surface );

	SDL_Event event;
	bool done = false;

	while ( !done ) {
		while ( SDL_PollEvent( &event ) ) {
			if ( event.type == SDL_QUIT ) {
				done = true;
			}
		}
	}

	cout << CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS << endl;
	CleanupOpenCL( oclData );
	SDL_Quit();
	return 0;
}

bool InitOpenCL( OpenCLData &oclData ) {

	// Get list of platforms
	cl_uint platformIdCount = 0;
    clGetPlatformIDs( 0, nullptr, &platformIdCount );
    std::vector<cl_platform_id> platformIds( platformIdCount );
    clGetPlatformIDs( platformIdCount, platformIds.data (), nullptr );

	// Get list of devices using the first found platform
	cl_uint deviceIdCount = 0;
    clGetDeviceIDs( platformIds[0], CL_DEVICE_TYPE_GPU, 0, nullptr,
		&deviceIdCount );
    std::vector<cl_device_id> deviceIds( deviceIdCount );
    clGetDeviceIDs( platformIds[0], CL_DEVICE_TYPE_GPU, deviceIdCount,
    deviceIds.data(), nullptr );

	const cl_context_properties contextProperties [] =
	{
		CL_CONTEXT_PLATFORM,
		reinterpret_cast<cl_context_properties>( platformIds[0] ),
		0, 0
	};

	cl_int error;
	oclData.context = clCreateContext( contextProperties, deviceIdCount,
		deviceIds.data(), nullptr, nullptr, &error );

	if ( error != CL_SUCCESS ) return false;

	oclData.queue = clCreateCommandQueue( oclData.context, deviceIds[0], 0, &error );
	if ( error != CL_SUCCESS ) {
		CleanupOpenCL( oclData );
		return false;
	}

	// Load kernel function from file
	FILE *fp = fopen( oclData.sourceFile, "r" );

	char *srcData = (char *)malloc( sizeof( char ) * 4096 );
	size_t srcSize = fread( srcData, sizeof( char ), 4096, fp );
	srcData[srcSize] = 0; // NULL-terminated

	fclose( fp );

	oclData.program = clCreateProgramWithSource( oclData.context, 1, (const char **)&srcData, &srcSize, &error );
	free( srcData );

	if ( error != CL_SUCCESS ) {
		CleanupOpenCL( oclData );
		return false;
	}

	error = clBuildProgram( oclData.program, 0, nullptr, nullptr, nullptr, nullptr );
	if ( error != CL_SUCCESS ) {
		CleanupOpenCL( oclData );
		return false;
	}

	oclData.kernel = clCreateKernel( oclData.program, oclData.kernelFunctionName, &error );
	if ( error != CL_SUCCESS ) {
		CleanupOpenCL( oclData );
		return false;
	}

	return true;
}

void CleanupOpenCL( OpenCLData &oclData ) {
	clReleaseKernel( oclData.kernel );
	clReleaseProgram( oclData.program );
	clReleaseCommandQueue( oclData.queue );
	clReleaseContext( oclData.context );
}

void SobelCL( SDL_Surface *surface, OpenCLData &oclData ) {
	unsigned int numPixels = surface->w * surface->h;
	unsigned int totalBytes = surface->format->BytesPerPixel * numPixels;

	cl_int error;
	cl_mem inputPixels = clCreateBuffer( oclData.context, CL_MEM_READ_ONLY, totalBytes, NULL, &error);
	cl_mem outputPixels = clCreateBuffer( oclData.context, CL_MEM_WRITE_ONLY, totalBytes, NULL, &error);

	clSetKernelArg( oclData.kernel, 0, sizeof( cl_mem ), &inputPixels );
	clSetKernelArg( oclData.kernel, 1, sizeof( cl_mem ), &outputPixels );
	clSetKernelArg( oclData.kernel, 2, sizeof( int ), &numPixels );
	clSetKernelArg( oclData.kernel, 3, sizeof( int ), &surface->w );
	clSetKernelArg( oclData.kernel, 4, sizeof( int ), &surface->h );

	error = clEnqueueWriteBuffer( oclData.queue, inputPixels, CL_FALSE, 0, totalBytes, surface->pixels, 0, NULL, NULL );
	error = clEnqueueNDRangeKernel( oclData.queue, oclData.kernel, 1, NULL, &numPixels, NULL, 0, NULL, NULL);
	error = clEnqueueReadBuffer( oclData.queue, outputPixels, CL_TRUE, 0, totalBytes, surface->pixels, 0, NULL, NULL);

	clReleaseMemObject( inputPixels );
	clReleaseMemObject( outputPixels );
}

void BlurImageCL( SDL_Surface *surface, int kernSize, OpenCLData &oclData ) {
	unsigned int numPixels = surface->w * surface->h;
	unsigned int totalBytes = surface->format->BytesPerPixel * numPixels;

	cl_int error;
	cl_mem inputPixels = clCreateBuffer( oclData.context, CL_MEM_READ_ONLY, totalBytes, NULL, &error);
	cl_mem outputPixels = clCreateBuffer( oclData.context, CL_MEM_WRITE_ONLY, totalBytes, NULL, &error);

	clSetKernelArg( oclData.kernel, 0, sizeof( cl_mem ), &inputPixels );
	clSetKernelArg( oclData.kernel, 1, sizeof( cl_mem ), &outputPixels );
	clSetKernelArg( oclData.kernel, 2, sizeof( int ), &numPixels );
	clSetKernelArg( oclData.kernel, 3, sizeof( int ), &surface->w );
	clSetKernelArg( oclData.kernel, 4, sizeof( int ), &surface->h );
	clSetKernelArg( oclData.kernel, 5, sizeof( int ), &kernSize );
	
	error = clEnqueueWriteBuffer( oclData.queue, inputPixels, CL_FALSE, 0, totalBytes, surface->pixels, 0, NULL, NULL );
	error = clEnqueueNDRangeKernel( oclData.queue, oclData.kernel, 1, NULL, &numPixels, NULL, 0, NULL, NULL);
	error = clEnqueueReadBuffer( oclData.queue, outputPixels, CL_TRUE, 0, totalBytes, surface->pixels, 0, NULL, NULL);

	clReleaseMemObject( inputPixels );
	clReleaseMemObject( outputPixels );
}

void GrayImage( SDL_Surface *surface ) {
	for ( int y = 0; y < surface->h; ++y ) {
		for ( int x = 0; x < surface->w; ++x ) {
			int pixel = ( ( int * ) surface->pixels )[ y * surface->w + x ];
			unsigned char alpha = ( pixel & 0xFF000000 ) >> 24;
			int value = ( pixel & 0x000000FF ) + ( ( pixel & 0x0000FF00 ) >> 8 ) + ( ( pixel & 0x00FF0000 ) >> 16 );
			value /= 3;

			( ( int * ) surface->pixels )[ y * surface->w + x ] = ( alpha << 24 ) | ( value << 16 ) | ( value << 8 ) | value;
		}
	}
}

void Sobel( SDL_Surface *surface ) {
	static const int kx[3][3] = { { 1, 0, -1 }, { 2, 0, -2 }, { 1, 0, -1 } };
	static const int ky[3][3] = { { 1, 2, 1 }, { 0, 0, 0 }, { -1, -2, -1 } };
	int *tmpPixels = ( int * ) malloc( 4 * surface->w * surface->h );

	for ( int y = 1; y < surface->h - 1; ++y ) {
		for ( int x = 1; x < surface->w - 1; ++x ) {
			int *pixel = ( int * ) surface->pixels;
			int gx = 0, gy = 0;

			for ( int j = -1; j <= 1; ++j ) {
				for ( int i = -1; i <= 1; ++i ) {
					gx += ( pixel[ ( y + j ) * surface->w + ( x + i ) ] & 0xFF ) * kx[ j + 1 ][ i + 1 ];
					gy += ( pixel[ ( y + j ) * surface->w + ( x + i ) ] & 0xFF ) * ky[ j + 1 ][ i + 1 ];
				}
			}

			int value = abs( gx ) + abs( gy );
			if ( value < 0 ) value = 0;
			else if ( value > 255 ) value = 255;

			int alpha = ( pixel[ y * surface->w + x ] & 0xFF000000 ) >> 24;
			tmpPixels[ y * surface->w + x ] = alpha << 24 | value << 16 | value << 8 | value;
		}
	}

	memcpy( surface->pixels, tmpPixels, 4 * surface->w * surface->h );
	free( tmpPixels );
}
