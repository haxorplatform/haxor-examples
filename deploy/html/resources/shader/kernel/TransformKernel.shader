<shader id="haxor/kernel/TransformKernel">	
		<vertex precision="high">
		
		attribute vec3 vertex;		
		
		varying vec2 iterator;
				
		void main(void) 
		{	
			gl_Position = vec4(vertex,1.0);
			iterator.x = (vertex.x+1.0)*0.5;
			iterator.y = (vertex.y+1.0)*0.5;
		}		
		</vertex>
		
		<fragment precision="high">
		
			#define FLAGS_OFFSET 		 0.0			
			#define POSITION_OFFSET 	 0.26			
			#define ROTATION_OFFSET 	 0.51			
			#define SCALE_OFFSET 		 0.76
			
			#define MATRIX_LENGTH    	 12.0			
			#define MATRIX_ROW_LENGTH    4.0			
			#define MATRIX_COL_LENGTH    1.0
			#define MAX_DEPTH 			 20
		
			float SHR(float v, float amt)  { return floor((floor(v) + 0.5) / exp2(amt));	}			
			float SHL(float v, float amt)  { return floor(v * exp2(amt) + 0.5); }			
			float MSK(float v, float bits) { return mod(v, SHL(1.0, bits)); }			
			float BITS(float num, float from, float to) { from = floor(from + 0.5); to   = floor(to + 0.5); return MSK(SHR(num, from), to - from); }
			
			/*
			vec4 F32ToRGBA (float v)
			{
				const vec4 bitSh = vec4(256 * 256 * 256, 256 * 256, 256, 1.0);
				const vec4 bitMsk = vec4(0, 1.0 / 256.0, 1.0 / 256.0, 1.0 / 256.0);
				vec4 comp = fract(v * bitSh);
				comp -= comp.xxyz * bitMsk;
				return comp;
			}
			
			float RGBAToF32 (vec4 v)
			{
				const vec4 bitShifts = vec4(1.0 / (256.0 * 256.0 * 256.0), 1.0 / (256.0 * 256.0), 1.0 / 256.0, 1.0);
				return dot(v, bitShifts);
			}
			//*/
			vec4 FToRGBA(float val) 
			{				
				if (val == 0.0) return vec4(0, 0, 0, 0);
				float sign = val > 0.0 ? 0.0 : 1.0;
				val = abs(val);
				float exponent = floor(log2(val));
				float biased_exponent = exponent + 127.0;
				float fraction = ((val / exp2(exponent)) - 1.0) * 8388608.0;
          
				float t = biased_exponent / 2.0;
				float last_bit_of_biased_exponent = fract(t) * 2.0;
				float remaining_bits_of_biased_exponent = floor(t);
          
				float byte4 = BITS(fraction, 0.0, 8.0) / 255.0;
				float byte3 = BITS(fraction, 8.0, 16.0) / 255.0;
				float byte2 = (last_bit_of_biased_exponent * 128.0 + BITS(fraction, 16.0, 23.0)) / 255.0;
				float byte1 = (sign * 128.0 + remaining_bits_of_biased_exponent) / 255.0;				
				return vec4(byte4, byte3, byte2, byte1);
			}
			
			
			
			
			mat4 TRS(vec4 p_position,vec4 p_rotation,vec4 p_scale)
			{										
				float x2 = p_rotation.x * p_rotation.x;
				float y2 = p_rotation.y * p_rotation.y;
				float z2 = p_rotation.z * p_rotation.z;		
				float xy = p_rotation.x * p_rotation.y;
				float xz = p_rotation.x * p_rotation.z;
				float yz = p_rotation.y * p_rotation.z;
				float xw = p_rotation.w * p_rotation.x;
				float yw = p_rotation.w * p_rotation.y;
				float zw = p_rotation.w * p_rotation.z;				
				float r00 = 1.0 - 2.0 * ( y2 + z2 );
				float r01 =       2.0 * ( xy - zw );
				float r02 =       2.0 * ( xz + yw );		
				float r10 =       2.0 * ( xy + zw );
				float r11 = 1.0 - 2.0 * ( x2 + z2 );
				float r12 =       2.0 * ( yz - xw );		
				float r20 =       2.0 * ( xz - yw );
				float r21 =       2.0 * ( yz + xw );
				float r22 = 1.0 - 2.0 * ( x2 + y2 );								
				mat4 r = mat4(
				r00 * p_scale.x,r01 * p_scale.y,r02 * p_scale.z,p_position.x,
				r10 * p_scale.x,r11 * p_scale.y,r12 * p_scale.z,p_position.y, 
				r20 * p_scale.x,r21 * p_scale.y,r22 * p_scale.z,p_position.z, 
				0,0,0,1);				
				return r;
			}
			
			mat4 identity() { return mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1); }
			
			float GetRowCol(int r,int c,mat4 m)
			{	
				if(r == 0)
				{
					if(c == 0) return m[0][0];
					if(c == 1) return m[0][1];
					if(c == 2) return m[0][2];
					if(c == 3) return m[0][3];
				}
				if(r == 1)
				{
					if(c == 0) return m[1][0];
					if(c == 1) return m[1][1];
					if(c == 2) return m[1][2];
					if(c == 3) return m[1][3];
				}
				if(r == 2)
				{
					if(c == 0) return m[2][0];
					if(c == 1) return m[2][1];
					if(c == 2) return m[2][2];
					if(c == 3) return m[2][3];
				}
				if(r == 3)
				{
					if(c == 0) return m[3][0];
					if(c == 1) return m[3][1];
					if(c == 2) return m[3][2];
					if(c == 3) return m[3][3];
				}
				return 0.0;
			}
			
			vec4 RCToRGBA(int r,int c,mat4 m)
			{
				return FToRGBA(GetRowCol(r,c,m));
			}
			
			void SampleFlags(sampler2D p_transform,float p_id,out vec4 p_flags)
			{
				p_id = 1.0 - p_id;
				//if(p_id < 0.0) 
				//{ 
					//p_flags = vec4(-1.0,0.0,0.0,1.0);
				//}
				//else
				//{
					p_flags = texture2D(p_transform, vec2(FLAGS_OFFSET,		1.0-p_id));
				//}
			}
			
			void SampleTransform(sampler2D p_transform,float p_id,out vec4 p_position,out vec4 p_rotation,out vec4 p_scale)
			{				
				p_id = 1.0 - p_id;
				//if(p_id < 0.0)
				//{
					//p_position = vec4(0,0,0,1);
					//p_rotation = vec4(0,0,0,1);
					//p_scale    = vec4(1,1,1,1);					
				//}
				//else
				//{ 								
					p_position = texture2D(p_transform, vec2(POSITION_OFFSET,	1.0-p_id));				
					p_rotation = texture2D(p_transform, vec2(ROTATION_OFFSET,	1.0-p_id));
					p_scale    = texture2D(p_transform, vec2(SCALE_OFFSET,		1.0-p_id));					
				//}
			}
			
			mat4 InverseTransform(mat4 m)
			{				
				float l0x = m[0][0]; float l0y = m[0][1]; float l0z = m[0][2]; float l0w =m[0][3];
				float l1x = m[1][0]; float l1y = m[1][1]; float l1z = m[1][2]; float l1w =m[1][3];
				float l2x = m[2][0]; float l2y = m[2][1]; float l2z = m[2][2]; float l2w =m[2][3]; 				
				float vl0 = sqrt(l0x * l0x + l1x * l1x + l2x * l2x);
				float vl1 = sqrt(l0y * l0y + l1y * l1y + l2y * l2y);
				float vl2 = sqrt(l0z * l0z + l1z * l1z + l2z * l2z);
				//length of the 3 lines of the 3x3 sector are the scales
				float sx = abs(vl0)<= 0.0001 ? 0.0 : (1.0/vl0); 
				float sy = abs(vl1)<= 0.0001 ? 0.0 : (1.0/vl1); 
				float sz = abs(vl2)<= 0.0001 ? 0.0 : (1.0/vl2); 				
				//normalized vector lines inside the 3x3 sector are the rotation axis.
				l0x *= sx; l0y *= sy; l0z *= sz;
				l1x *= sx; l1y *= sy; l1z *= sz;
				l2x *= sx; l2y *= sy; l2z *= sz;				
				return mat4(
				sx * l0x, sx * l1x, sx * l2x, sx * ((l0x * -l0w) + (l1x * -l1w) + (l2x * -l2w)),
				sy * l0y, sy * l1y, sy * l2y, sy * ((l0y * -l0w) + (l1y * -l1w) + (l2y * -l2w)),
				sz * l0z, sz * l1z, sz * l2z, sz * ((l0z * -l0w) + (l1z * -l1w) + (l2z * -l2w)),
				0,0,0,1
				);						
			}
			
			uniform sampler2D Transform;
			
			uniform sampler2D Output;
			
			uniform float width;
			
			uniform float height;
			
			varying vec2 iterator;
			
			float h[MAX_DEPTH];
			
			void main(void) 
			{		
				float ix	     = iterator.x;
				float iy	     = iterator.y;
				float px         = (ix*width);				
								
				int   mtx_id     = int(px / MATRIX_LENGTH);
				
				vec4 d;
				
				vec4  flags;
				vec4  position;
				vec4  rotation;
				vec4  scale;
				
				//SampleTransform(Transform,iy,position,rotation,scale);
				//d = vec4(rotation.xyz,1);	gl_FragColor = d;return;
				
				SampleFlags(Transform,iy,flags);
				
				//LocalMatrix				
				if(mtx_id == 0)
				{				
					//if(flags.y <= 0.0) discard;
					//if(flags.y <= 0.0) { gl_FragColor = texture2D(Output,iterator); return; }
					
					float mrow   	 = mod(floor(px / MATRIX_ROW_LENGTH),3.0);
					int   mtx_row    = int(mrow);
					float mcol   	 = mod(floor(px / MATRIX_COL_LENGTH),4.0);
					int   mtx_col    = int(mcol);
					
					SampleTransform(Transform,iy,position,rotation,scale);				
					mat4 lm = TRS(position,rotation,scale);
					gl_FragColor = RCToRGBA(mtx_row,mtx_col,lm);					
					return;
				}
				else
				//WorldMatrix
				if((mtx_id == 1) || (mtx_id == 2))
				{
					//if(flags.z <= 0.0) discard;
					//if(flags.z <= 0.0) { gl_FragColor = texture2D(Output,iterator); return; }
					
					float mrow   	 = mod(floor(px / MATRIX_ROW_LENGTH),3.0);
					int   mtx_row    = int(mrow);
					float mcol   	 = mod(floor(px / MATRIX_COL_LENGTH),4.0);
					int   mtx_col    = int(mcol);
					
					float pid = flags.x;
					
					for(int i=0;i<MAX_DEPTH;i++)
					{
						h[i]  = pid;
						if(pid >= 0.0)
						{
							SampleFlags(Transform,(pid / (height-1.0)),flags); 						
							pid = flags.x;
						}						
					}
					
					mat4 wm = identity();					
					for(int i=MAX_DEPTH-1;i>=0;i--)
					{						
						pid = h[i];
						if(pid >= 0.0)
						{
							SampleTransform(Transform,pid/(height-1.0),position,rotation,scale);						
							wm = TRS(position,rotation,scale) * wm;						
						}
					}
					
					SampleTransform(Transform,iy,position,rotation,scale);				
					mat4 lm = TRS(position,rotation,scale);
					
					wm = lm * wm;
					
					if(mtx_id==1) { gl_FragColor = RCToRGBA(mtx_row,mtx_col,wm); return; }
					if(mtx_id==2) { gl_FragColor = RCToRGBA(mtx_row,mtx_col,InverseTransform(wm)); return; }
					
					return;
				}
				
				gl_FragColor = d;
				
			}
			
		</fragment>	
</shader>