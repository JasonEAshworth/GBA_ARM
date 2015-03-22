
__kernel void ckSobel(__global uchar4* uc4Source, __global unsigned int* uiDest,
                      __local uchar4* uc4LocalData, int iLocalPixPitch, 
                      int iImageWidth, int iDevImageHeight, float fThresh)
{
    
    int iImagePosX = get_global_id(0);
    int iDevYPrime = get_global_id(1) - 1;  
    int iDevGMEMOffset = mul24(iDevYPrime, (int)get_global_size(0)) + iImagePosX; 

   
    int iLocalPixOffset = mul24((int)get_local_id(1), iLocalPixPitch) + get_local_id(0) + 1;

  
    if((iDevYPrime > -1) && (iDevYPrime < iDevImageHeight) && (iImagePosX < iImageWidth))
    {
        uc4LocalData[iLocalPixOffset] = uc4Source[iDevGMEMOffset];
    }
    else 
    {
        uc4LocalData[iLocalPixOffset] = (uchar4)0; 
    }

   
    if (get_local_id(1) < 2)
    {
       
        iLocalPixOffset += mul24((int)get_local_size(1), iLocalPixPitch);

      
        if (((iDevYPrime + get_local_size(1)) < iDevImageHeight) && (iImagePosX < iImageWidth))
        {
          
            uc4LocalData[iLocalPixOffset] = uc4Source[iDevGMEMOffset + mul24(get_local_size(1), get_global_size(0))];
        }
        else 
        {
            uc4LocalData[iLocalPixOffset] = (uchar4)0; 
        }
    }

  
    if (get_local_id(0) == (get_local_size(0) - 1))
    {
     
        iLocalPixOffset = mul24((int)get_local_id(1), iLocalPixPitch);

      
        if ((iDevYPrime > -1) && (iDevYPrime < iDevImageHeight) && (get_group_id(0) > 0))
        {
  
            uc4LocalData[iLocalPixOffset] = uc4Source[mul24(iDevYPrime, (int)get_global_size(0)) + mul24(get_group_id(0), get_local_size(0)) - 1];
        }
        else 
        {
            uc4LocalData[iLocalPixOffset] = (uchar4)0; 
        }

      
        if (get_local_id(1) < 2)
        {
          
            iLocalPixOffset += mul24((int)get_local_size(1), iLocalPixPitch);

          
            if (((iDevYPrime + get_local_size(1)) < iDevImageHeight) && (get_group_id(0) > 0))
            {
               
                uc4LocalData[iLocalPixOffset] = uc4Source[mul24((iDevYPrime + (int)get_local_size(1)), (int)get_global_size(0)) + mul24(get_group_id(0), get_local_size(0)) - 1];
            }
            else 
            {
                uc4LocalData[iLocalPixOffset] = (uchar4)0; 
            }
        }
    } 
    else if (get_local_id(0) == 0)
       
        iLocalPixOffset = mul24(((int)get_local_id(1) + 1), iLocalPixPitch) - 1;

        if ((iDevYPrime > -1) && (iDevYPrime < iDevImageHeight) && (mul24(((int)get_group_id(0) + 1), (int)get_local_size(0)) < iImageWidth))
        {
            
            uc4LocalData[iLocalPixOffset] = uc4Source[mul24(iDevYPrime, (int)get_global_size(0)) + mul24((get_group_id(0) + 1), get_local_size(0))];
        }
        else 
        {
            uc4LocalData[iLocalPixOffset] = (uchar4)0; 
        }


        if (get_local_id(1) < 2)
        {

            iLocalPixOffset += (mul24((int)get_local_size(1), iLocalPixPitch));

            if (((iDevYPrime + get_local_size(1)) < iDevImageHeight) && (mul24((get_group_id(0) + 1), get_local_size(0)) < iImageWidth) )
            {
               
                uc4LocalData[iLocalPixOffset] = uc4Source[mul24((iDevYPrime + (int)get_local_size(1)), (int)get_global_size(0)) + mul24((get_group_id(0) + 1), get_local_size(0))];
            }
            else 
            {
                uc4LocalData[iLocalPixOffset] = (uchar4)0; 
            }
        }
    }


    barrier(CLK_LOCAL_MEM_FENCE);


    float fTemp = 0.0f; 
    float fHSum [3] = {0.0f, 0.0f, 0.0f};
    float fVSum [3] = {0.0f, 0.0f, 0.0f};


    iLocalPixOffset = mul24((int)get_local_id(1), iLocalPixPitch) + get_local_id(0);

    // NW
	fHSum[0] += (float)uc4LocalData[iLocalPixOffset].x;   
	fHSum[1] += (float)uc4LocalData[iLocalPixOffset].y;   
	fHSum[2] += (float)uc4LocalData[iLocalPixOffset].z;   
    fVSum[0] -= (float)uc4LocalData[iLocalPixOffset].x;   
	fVSum[1] -= (float)uc4LocalData[iLocalPixOffset].y;   
	fVSum[2] -= (float)uc4LocalData[iLocalPixOffset++].z; 

    // N
	fVSum[0] -= (float)(uc4LocalData[iLocalPixOffset].x << 1);  
	fVSum[1] -= (float)(uc4LocalData[iLocalPixOffset].y << 1);  
	fVSum[2] -= (float)(uc4LocalData[iLocalPixOffset++].z << 1);

    // NE
	fHSum[0] -= (float)uc4LocalData[iLocalPixOffset].x;    
	fHSum[1] -= (float)uc4LocalData[iLocalPixOffset].y;    
	fHSum[2] -= (float)uc4LocalData[iLocalPixOffset].z;    
	fVSum[0] -= (float)uc4LocalData[iLocalPixOffset].x;    
	fVSum[1] -= (float)uc4LocalData[iLocalPixOffset].y;    
	fVSum[2] -= (float)uc4LocalData[iLocalPixOffset].z;    


    iLocalPixOffset += (iLocalPixPitch - 2);    
                
    // W
	fHSum[0] += (float)(uc4LocalData[iLocalPixOffset].x << 1);  
	fHSum[1] += (float)(uc4LocalData[iLocalPixOffset].y << 1);  
	fHSum[2] += (float)(uc4LocalData[iLocalPixOffset++].z << 1);

    // C
    iLocalPixOffset++;

    // E
	fHSum[0] -= (float)(uc4LocalData[iLocalPixOffset].x << 1);  
	fHSum[1] -= (float)(uc4LocalData[iLocalPixOffset].y << 1);  
	fHSum[2] -= (float)(uc4LocalData[iLocalPixOffset].z << 1);  


    iLocalPixOffset += (iLocalPixPitch - 2);    

    // SW
	fHSum[0] += (float)uc4LocalData[iLocalPixOffset].x;    
	fHSum[1] += (float)uc4LocalData[iLocalPixOffset].y;    
	fHSum[2] += (float)uc4LocalData[iLocalPixOffset].z;    
	fVSum[0] += (float)uc4LocalData[iLocalPixOffset].x;    
	fVSum[1] += (float)uc4LocalData[iLocalPixOffset].y;    
	fVSum[2] += (float)uc4LocalData[iLocalPixOffset++].z;  

    // S
	fVSum[0] += (float)(uc4LocalData[iLocalPixOffset].x << 1); 
	fVSum[1] += (float)(uc4LocalData[iLocalPixOffset].y << 1); 
	fVSum[2] += (float)(uc4LocalData[iLocalPixOffset++].z << 1);

    // SE
	fHSum[0] -= (float)uc4LocalData[iLocalPixOffset].x;    
	fHSum[1] -= (float)uc4LocalData[iLocalPixOffset].y;    
	fHSum[2] -= (float)uc4LocalData[iLocalPixOffset].z;    
	fVSum[0] += (float)uc4LocalData[iLocalPixOffset].x;    
	fVSum[1] += (float)uc4LocalData[iLocalPixOffset].y;    
	fVSum[2] += (float)uc4LocalData[iLocalPixOffset].z;    


	fTemp =  0.30f * sqrt((fHSum[0] * fHSum[0]) + (fVSum[0] * fVSum[0]));
	fTemp += 0.55f * sqrt((fHSum[1] * fHSum[1]) + (fVSum[1] * fVSum[1]));
	fTemp += 0.15f * sqrt((fHSum[2] * fHSum[2]) + (fVSum[2] * fVSum[2]));

    if (fTemp < fThresh)
    {
        fTemp = 0.0f;
    }
    else if (fTemp > 255.0f)
    {
        fTemp = 255.0f;
    }


    unsigned int uiPackedPix = 0x000000FF & (unsigned int)fTemp;
    uiPackedPix |= 0x0000FF00 & (((unsigned int)fTemp) << 8);
    uiPackedPix |= 0x00FF0000 & (((unsigned int)fTemp) << 16);


    if((iDevYPrime + 1 < iDevImageHeight) && (iImagePosX < iImageWidth))
    {
        uiDest[iDevGMEMOffset + get_global_size(0)] = uiPackedPix;
    }
}
