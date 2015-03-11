<shader id="haxor/filter/Bloom">	
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
			
			uniform sampler2D Blur;
			
			uniform float Factor;
			
			varying vec2 uv;
			
			void main(void) 
			{					
				vec4 t = texture2D(Texture,uv);				
				vec4 b = texture2D(Blur,uv);
				gl_FragColor = t + (b * Factor);
				
			}
			
		</fragment>	
</shader>