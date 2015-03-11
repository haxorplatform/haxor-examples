<shader id="haxor/kernel/Basic">	
		<vertex precision="high">
		
		attribute vec3 vertex;		
		
		varying vec2 iterator;
		
		void main(void) 
		{	
			gl_Position = vec4(vertex,1.0);
			iterator.x = (vertex.x+1.0)*0.5;
			iterator.y = (-vertex.y+1.0)*0.5;
		}		
		</vertex>
		
		<fragment precision="high">
			
			float SHR(float v, float amt)  { return floor((floor(v) + 0.5) / exp2(amt));	}			
			float SHL(float v, float amt)  { return floor(v * exp2(amt) + 0.5); }			
			float MSK(float v, float bits) { return mod(v, SHL(1.0, bits)); }			
			float BITS(float num, float from, float to) { from = floor(from + 0.5); to   = floor(to + 0.5); return MSK(SHR(num, from), to - from); }
			
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
			
			uniform sampler2D Input;
			
			uniform float width;
			
			uniform float height;
			
			uniform float Time;
			
			varying vec2 iterator;
			
			void main(void) 
			{		
				float w = (width*0.25);
				float px = iterator.x*w;
				float py = iterator.y*height;
							
				
				int ch   = int(iterator.x*width);
				vec4 v = texture2D(Input, iterator);
				if(int(w)>=64) v = vec4(0,1,0,1);
				vec4 d = v;
				if(ch == 0) d = FToRGBA(d.x);
				if(ch == 1) d = FToRGBA(d.y);
				if(ch == 2) d = FToRGBA(d.z);
				if(ch == 4) d = FToRGBA(d.w);
				gl_FragColor = v;
				
			}
			
		</fragment>	
</shader>