<shader id="haxor/filter/Red">	
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
			
			varying vec2 uv;
			
			void main(void) 
			{	
				vec4 c = texture2D(Texture,uv);
				c.gb = vec2(0.0);
				gl_FragColor = c;
				
			}
			
		</fragment>	
</shader>