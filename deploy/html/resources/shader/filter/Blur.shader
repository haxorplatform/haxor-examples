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
			
			uniform float Strength;
			
			varying vec2 uv;
			
			void main(void) 
			{	
				float s = 0.0005 * Strength;				
				float w = 1.0 / 9.0;
				vec4 c = vec4(0);
				c += texture2D(Texture,vec2(uv.x-s,uv.y-s)) * w;
				c += texture2D(Texture,vec2(uv.x  ,uv.y-s)) * w;
				c += texture2D(Texture,vec2(uv.x+s,uv.y-s)) * w;
				c += texture2D(Texture,vec2(uv.x-s,uv.y  )) * w;
				c += texture2D(Texture,vec2(uv.x  ,uv.y  )) * w;
				c += texture2D(Texture,vec2(uv.x+s,uv.y  )) * w;
				c += texture2D(Texture,vec2(uv.x-s,uv.y+s)) * w;
				c += texture2D(Texture,vec2(uv.x  ,uv.y+s)) * w;
				c += texture2D(Texture,vec2(uv.x+s,uv.y+s)) * w;				
				gl_FragColor = c;
				
			}
			
		</fragment>	
</shader>