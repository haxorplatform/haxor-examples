<shader id="haxor/kernel/Debug">	
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
			
			uniform sampler2D Input;
			
			varying vec2 iterator;
			
			void main(void) 
			{					
				vec4 d = texture2D(Input, iterator);										
				gl_FragColor = d;
			}
			
		</fragment>	
</shader>