__kernel void Blur( __global uchar4 *in, __global uchar4 *out, int num, int width, int height, int kernSize)
{
    // find position in global arrays
    int iGID = get_global_id(0);

    // bound check (equivalent to the limit on a 'for' loop for standard/serial C code
    if (iGID >= num)
    {   
       return; 
    }

	int y = iGID / width;
	int x = iGID % width;

	int b = kernSize >> 1;

	if ( ( x - b ) < 0 || ( x + b ) >= width || ( y - b ) < 0 || ( y + b ) >= height ) {
		out[ iGID ] = in[ iGID ];
		return;
	}

	int4 colorAvg = { 0, 0, 0, 0 };
	for ( int i = -b; i <= b; ++i ) {
		for ( int j = -b; j <= b; ++j ) {
			uchar4 v = in[ ( y + j ) * width + ( x + i ) ];
			int4 color = { v.x, v.y, v.z, 0 };
			colorAvg += color;
		}
	}

	colorAvg /= kernSize * kernSize;

	out[ iGID ].x = colorAvg.x;
	out[ iGID ].y = colorAvg.y;
	out[ iGID ].z = colorAvg.z;
	out[ iGID ].w = in[ iGID ].w;
}
