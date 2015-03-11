<shader id="haxor/filter/Blur">	
		<vertex precision="low">
		
		attribute vec3 vertex;		
		
		varying vec2 uv;
		
		void main(void) 
		{	
			gl_Position = vec4(vertex,1.0);
			uv.x = (vertex.x+1.0)*0.5;
			uv.y = (vertex.y+1.0)*0.5;
		}		
		</vertex>
		
		<fragment precision="low">
			
			uniform sampler2D Texture;
			
			uniform sampler2D Depth;
			
			uniform vec4 Color;
			
			uniform float Exp;
			
			uniform float Factor;
			
			uniform float Near;
			
			uniform float Far;
			
			varying vec2 uv;
			
			float DepthToLinear(float p_depth,float p_near,float p_far) { return p_depth / (p_far - p_depth * (p_far - p_near)); }
			
			void main(void) 
			{	
				vec4  c = texture2D(Texture,uv);
				float f = DepthToLinear(texture2D(Depth,uv).x,Near,Far);
				
				f = pow(f,Exp);	
				f = clamp(f*pow(Factor,Exp),0.0,1.0);
				
				gl_FragColor = c + (Color- c)*f;
				//gl_FragColor = vec4(f,f,f,1.0);
				
			}
			
		</fragment>	
</shader>